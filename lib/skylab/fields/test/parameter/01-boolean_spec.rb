require_relative '../test-support'

describe '[fi] P - boolean: given "object" with parameter "foo"' do

  extend Skylab::Fields::TestSupport
  use :parameter

  context 'and "foo" is boolean' do

    with do
      param :finished, :boolean
    end

    frame do

      it '"object.foo?" is a reader of the (presumably boolean) value' do

        object_.finished?.should be_nil
      end

      it '"object.foo!" is a DSL-y writer that sets the parameter ' <<
        'value of "foo" to true' do

        object = object_
        object.finished!
        object.finished?.should eql(true)
      end

      it '"object.not_foo!" is a DSL-y writer that sets the parameter value ' <<
        'of "foo" to false' do

        object = object_
        object.not_finished!
        object.finished?.should eql(false)
      end

      it '"object.foo", however, (a reader) you do not get ' <<
        'out of the box just like that.' do

        o = object_
        begin
          o.finished
        rescue ::NoMethodError => e
        end
        e or fail
      end

      it '"object.foo = x", however, (the writer) you do not just get ' <<
        'out of the box just like that just for doing nothing ' do

        o = object_
        begin
          o.finished = true
        rescue ::NoMethodError => e
        end
        e or fail
      end
    end
  end
end
