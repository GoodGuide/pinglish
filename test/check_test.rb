require "helper"

class PinglishCheckTest < MiniTest::Unit::TestCase
  def test_initialize
    check = Pinglish::Check.new(:db)
    assert_equal :db, check.name
  end

  def test_initialize_default_timeout
    check = Pinglish::Check.new(:db)
    assert_equal 1, check.timeout
  end

  def test_initialize_override_timeout
    check = Pinglish::Check.new(:db, :timeout => 2)
    assert_equal 2, check.timeout
  end

  def test_call
    check = Pinglish::Check.new(:db) { :result_of_block }
    assert_equal :result_of_block, check.call
  end

  def test_enabled_by_default
    check = Pinglish::Check.new(:foo)
    assert_equal true, check.enabled_by_default

    check = Pinglish::Check.new(:foo, enabled_by_default: false)
    assert_equal false, check.enabled_by_default

    check = Pinglish::Check.new(:foo, enabled_by_default: 'not boolean')
    assert_equal true, check.enabled_by_default
  end
end
