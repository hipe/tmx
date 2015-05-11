require_relative 'test-support'

describe '[hl] If you have an object "object" that has a ' <<
  "#{::Skylab::Headless::Parameter} \"foo\"" do

  extend ::Skylab::Headless::TestSupport::Parameter
  context 'and "foo" either does or doesn\'t have "default: \'anything\'"' do
    let(:foo) { klass.parameters[:foo] }
    context 'if you gave "foo" the property "default: :wazoo"' do
      with do
        param :foo, default: :wazoo
      end
      frame do
        it '"foo.has_default?" is true' do
          foo.has_default?.should eql(true)
        end
        it '"foo.default_value" is :wazoo' do
          foo.default_value.should eql(:wazoo)
        end
      end
    end
    context "if you did not give it any default assignment" do
      with do
        param :foo
      end
      frame do
        it '"foo.has_default?" is false-ish' do
          foo.has_default?.should eql(false)
        end
        it '"foo.default_value" raises a NoMethodError' do
          -> { foo.default_value }.should raise_error(::NoMethodError)
        end
      end
    end
    context "if you give it a false-ish (nil or false) default value" do
      with do
        param :foo, default: nil
      end
      frame do
        it '"foo.has_default?" is true' do
          foo.has_default?.should eql(true)
        end
        it '"foo.default_value" is accurate' do
          foo.default_value.should be_nil
        end
      end
    end
  end
end
