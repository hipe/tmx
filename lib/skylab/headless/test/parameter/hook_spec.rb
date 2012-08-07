require_relative 'test-support.rb'

describe "#{::Skylab::Headless::Parameter} hook: true" do
  extend ::Skylab::Headless::Parameter::TestSupport
  defn do
    param :on_error, hook: true
  end
  frame do
    it "you get a foo reader (whose result is nil by default)" do
      object.on_error.should be_nil
    end
    it "foo { ... } will write a lambda to the parameter value" do
      object.on_error { }
      object.send(:[], :on_error).should be_kind_of(::Proc)
    end
    it "foo.call will call the proc (when set)" do
      canary = :red
      object.on_error { canary = :blue }
      canary.should eql(:red)
      object.on_error.call
      canary.should eql(:blue)
    end
  end
end
