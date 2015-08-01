require_relative '../test-support'

describe '[fi] given "object" with parameter "foo"' do

  extend Skylab::Fields::TestSupport
  use :parameter

  context 'and "foo" has the property "hook: true"' do

    with do
      param :on_error, hook: true
    end

    frame do

      it '"object.foo" is a reader (whose result is nil by default)' do

        object.send(:known?, :on_error).should eql(false)
      end

      it '"object.foo { .... }" is a writer that sets the parameter ' <<
           'value to that proc (the proc, not the proc\'s result' do

        object = send :object
        object.on_error { }
        object.send(:[], :on_error).should be_kind_of(::Proc)
      end

      it '"object.foo.call" will then call that proc (when set)' do

        object = send :object
        canary = :red
        object.on_error { canary = :blue }
        canary.should eql(:red)
        object.on_error.call
        canary.should eql(:blue)
      end
    end
  end
end
