require_relative 'test-support'
require 'pathname' # already required by whoever but whatever

describe 'If you have an object "object" that has a ' <<
  "#{::Skylab::Headless::Parameter} \"foo\" " do

  extend ::Skylab::Headless::Parameter::TestSupport
  context 'and "foo" has the property "pathname: true"' do
    context 'out of the box you get a reader but no writer..' do
      # ..because no writer simply wouldn't make sense!
      defn do
        param :foo, pathname: true
      end
      frame do
        it '"object.foo" is not defined for you (no reader)' do
          -> { object.foo }.should raise_error(::NoMethodError)
        end
        it '"object.foo =\'x\'" turns \'x\' into a Pathname at calltime' do
          object.foo = 'x'
          object.send(:[], :foo).should be_kind_of(::Pathname)
        end
        it '"object.foo = <a falseish>", however, does not a Pathname make.' do
          object.foo = 'x'
          object.send(:[], :foo).should be_kind_of(::Pathname)
          object.foo = false
          object.send(:[], :foo).should eql(false)
        end
      end
    end
  end
end
