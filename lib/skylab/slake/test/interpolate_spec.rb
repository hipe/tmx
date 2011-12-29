require File.expand_path('../../interpolate', __FILE__)

describe Skylab::Slake::Interpolate do
  it "works" do
    src = Struct.new(:a, :b).new('one', 'two')
    subject.interpolate('{a}AND{b}', src).should eql('oneANDtwo')
  end
  describe "with circular dependencies" do
    let(:klass) do
      Class.new.class_eval do
        def self.to_s ; 'Foo' end
        include Skylab::Slake::Interpolator
        def one
          interpolate "{two}"
        end
        def two
          interpolate "{four}{three}"
        end
        def three
          interpolate "{four}{one}"
        end
        def four
          'ok'
        end
        self
      end
    end
    it "can guarantee protection" do
      lambda{ klass.new.one }.should raise_exception(::RuntimeError, 'circular depdendency: Foo#two')
    end
  end
end

