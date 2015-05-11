require_relative 'test-support'

describe '[hl] If you have an object "object" that has a ' <<
  "#{::Skylab::Headless::Parameter} \"foo\" " do

  extend ::Skylab::Headless::TestSupport::Parameter
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
        object.on_error { }
        object.send(:[], :on_error).should be_kind_of(::Proc)
      end
      it '"object.foo.call" will then call that proc (when set)' do
        canary = :red
        object.on_error { canary = :blue }
        canary.should eql(:red)
        object.on_error.call
        canary.should eql(:blue)
      end
    end
  end
end
