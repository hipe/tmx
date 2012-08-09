require_relative 'test-support'

describe "#{::Skylab::Headless}(meta)Parameters" do
  extend ::Skylab::Headless::Parameter::TestSupport
  context 'can be defined inline alongside parameters with "meta_param"' do
    defn do
      meta_param :inheritable, boolean: true, writer: true
      param :direction, inheritable: true
    end
    frame do
      it 'and they can then be used in property assignments ' <<
        'on subsequent parameter definitions WOW!' do
        param = object.class.parameters[:direction]
        param.inheritable?.should eql(true)
      end
    end
  end
end
