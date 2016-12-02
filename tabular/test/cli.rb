require 'minitest/autorun'
root = File.expand_path('../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)
require 'assess'

class MiniTest::Unit::TestCase

  # will rewrite.
end
# #tombstone: full reconception from ancient [as]
