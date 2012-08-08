require_relative 'test-support'

describe 'If you have an object "object" with a ' <<
  "#{::Skylab::Headless::Parameter} \"foo\"" do

  extend ::Skylab::Headless::Parameter::TestSupport

  context 'and "foo" has the property of e.g. "enum: [:alpha, :beta]"' do
    context 'you get no readers or writers out of the box so..' do
      defn do
        param :color, enum: [:red, :blue]
      end
      frame do
        it '"object.foo" and "object.foo = x" you do not have' do
          ->{ object.color }.should raise_error(::NoMethodError)
          ->{ object.color = :red }.should raise_error(::NoMethodError)
        end
      end
    end
    context 'but if "foo" also has the property "writer: true"' do
      defn do
        param :color, enum: [:red, :blue], writer: true
      end
      frame do
        it '"object.foo = :beta" (a valid value) changes the parameter value' do
          object.send(:[], :color).should be_nil
          object.color = :blue
          object.send(:[], :color).should eql(:blue)
        end
        it('"object.foo = :gamma" (an invalid value) will use the host ' <<
           'instance\'s _with_client method to emit an error message') do
          object.color = :orange
          out.shift.should match(/:orange is an invalid value for .*color/i)
          out.size.should eql(0)
        end
      end
    end
  end
end
