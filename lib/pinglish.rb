require 'json'
require 'pinglish/check'
require 'rack/request'

# This Rack app provides an endpoint for configurable
# system health checks. It's intended to be consumed by machines.

class Pinglish

  # The HTTP headers sent for every response.
  HEADERS = {
    'Content-Type' => 'application/json; charset=UTF-8'
  }

  # Create a new instance of the app; yields itself to an optional block for configuring checks.
  def initialize(options=nil, &block)
    options ||= {}

    @checks = {}

    yield(self) if block_given?
  end

  def call(env)
    request = Rack::Request.new(env)
    results = {}

    selected_checks(request.params).each do |check|
      check_thread = Thread.new do
        check.call
      end
      sleep_thread = Thread.new do
        sleep check.timeout
        check_thread.kill
        :timeout
      end
      begin
        val = check_thread.value
      rescue => e
        val = e
      end
      sleep_thread.kill
      results[check.name] = sleep_thread.value || val
    end

    failed = results.values.any? { |v| failure?(v) }
    http_status = failed ? 503 : 200
    text_status = failed ? 'failures' : 'ok'

    data = {
      now: Time.now.to_i,
      status: text_status,
    }

    results.each do |name, value|
      if timeout?(value)
        # If the check failed because it timed out, its name is
        # added to a `timeouts` array instead.
        (data[:timeouts] ||= []) << name

      elsif failure?(value)
        # If a check fails its name is added to a `failures` array.

        (data[:failures] ||= []) << name

        if value.is_a?(Exception)
          data[name] = {
            state: :error,
            exception: value.class.name,
            message: value.message,
          }
        end

      elsif value
        # If the check passed and returned a value, the stringified
        # version of the value is returned under the `name` key.

        data[name] = value
      end
    end

    [http_status, HEADERS, [JSON.generate(data)]]

  rescue Exception => ex
    # Something catastrophic happened. We can't even run the checks
    # and render a JSON response. Fall back on a pre-rendered string
    # and interpolate the current epoch time.

    now = Time.now.to_i

    body = <<-EOF.gsub(/^ {6}/, '')
      {
        "status": "failures",
        "now": #{now},
        "error": {
          "class": "#{ex.class.name}",
          "message": "#{ex.message.tr('"', '')}"
        }
      }
    EOF

    [500, HEADERS, [body]]
  end

  def selected_checks(params)
    if (selected = params['checks'])
      selected = selected.split(',').map(&:to_sym)
      return @checks.values_at(*selected).compact
    end
    @checks.values.select(&:enabled_by_default)
  end

  # Add a new check with optional `name`. A `:timeout` option can be
  # specified in seconds for checks that might take longer than the
  # one second default. A previously added check with the same name
  # will be replaced.

  def check(name=:default, options={}, &block)
    @checks[name.to_sym] = Check.new(name, options, &block)
  end

  # Does `value` represent a check failure? This default
  # implementation returns `true` for any value that is an Exception or false.
  # Subclasses can override this method for different behavior.

  def failure?(value)
    value.is_a?(Exception) || value == false || timeout?(value)
  end

  def timeout?(value)
    value == :timeout
  end
end
