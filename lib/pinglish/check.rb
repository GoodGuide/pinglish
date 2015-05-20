class Pinglish
  class Check
    attr_reader :name
    attr_reader :timeout
    attr_reader :enabled_by_default

    def initialize(name, options={}, &block)
      @name = name
      @timeout = options.fetch(:timeout, 1)
      @enabled_by_default = !!options.fetch(:enabled_by_default, true)
      @block = block
    end

    # Call this check's behavior, returning the result of the block.
    def call(*args, &block)
      @block.call(*args, &block)
    end
  end
end
