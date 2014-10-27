require_relative 'test-support'

describe "[hl] parameters - meta-parameters" do

  extend ::Skylab::Headless::TestSupport::Parameter

  context 'can be defined inline alongside parameters with "meta_param"' do

    with do
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
