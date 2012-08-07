require_relative 'test-support.rb'

describe "#{::Skylab::Headless::Parameter} boolean: true" do
  extend ::Skylab::Headless::Parameter::TestSupport
  defn do
    param :finished, boolean: true
  end
  frame do
    it "you get a foo? reader (whose result is nil by default)" do
      object.finished?.should be_nil
    end
    it "foo! will set it to true" do
      object.finished!
      object.finished?.should eql(true)
    end
    it "not_foo! will set it to false" do
      object.not_finished!
      object.finished?.should eql(false)
    end
    it "foo() however, (plain old reader) is not out of the box defined" do
      -> { object.finished }.should raise_error(::NoMethodError)
    end
  end
end
