require_relative 'test-support'

describe "If you have an object \"object\" that has a " <<
  "#{::Skylab::Headless::Parameter} \"foo\" " do
  extend ::Skylab::Headless::TestSupport::Parameter
  context 'and "foo" has the property "boolean: true"' do
    with do
      param :finished, boolean: true
    end
    frame do
      it '"object.foo?" is a reader of the (presumably boolean) value ' <<
        '(note it used to return nil out of the box, now false)' do
        object.finished?.should eql(false)
      end
      it '"object.foo!" is a DSL-y writer that sets the parameter ' <<
        'value of "foo" to true' do
        object.finished!
        object.finished?.should eql(true)
      end
      it '"object.not_foo!" is a DSL-y writer that sets the parameter value ' <<
        'of "foo" to false' do
        object.not_finished!
        object.finished?.should eql(false)
      end
      it '"object.foo", however, (a reader) you do not get ' <<
        'out of the box just like that.' do
        -> { object.finished }.should raise_error(::NoMethodError)
      end
      it '"object.foo = x", however, (the writer) you do not just get ' <<
        'out of the box just like that just for doing nothing ' do
        -> { object.finished = true }.should raise_error(::NoMethodError)
      end
    end
  end
end
