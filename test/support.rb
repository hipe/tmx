require 'minitest/autorun'
root = File.expand_path('../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)
require 'assess'

class MiniTest::Unit::TestCase
  def assert_superset(expected, actual, msg=nil)
    missing = expected - actual
    if missing.any?
      msg = "#{msg} missing keys: (#{missing.join(', ')})"
      assert false, msg
    else
      assert true, msg
    end
  end
  def assert_equal_set(expected, actual, msg=nil)
    missing = expected - actual
    extra   = actual - expected
    if ! missing.any? && ! extra.any?
      assert true
    else
      if missing.any?
        assert(false, "required #{msg} missing: (#{missing.join(', ')})")
      end
      if extra.any?
        assert(false, "unexpected #{msg}: (#{extra.join(', ')})")
      end
    end
  end
end
