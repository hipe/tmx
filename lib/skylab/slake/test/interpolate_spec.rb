require_relative 'test-support'

Skylab::TestSupport::Quickie.enable_kernel_describe

module Skylab::Slake  # [#ts-010]
# ..
describe Slake::Interpolate do
  # include ::Skylab::Slake

  it "works" do
    src = ::Struct.new(:a, :b).new('one', 'two')
    Interpolate.interpolate( '{a}AND{b}', src ).
      should eql( 'oneANDtwo' )
  end

  describe "with circular dependencies" do
    let(:klass) do
      ::Class.new.class_eval do
        def self.to_s ; 'Foo' end
        include Slake::Interpolator
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
      -> do
        klass.new.one
      end.should raise_error( ::RuntimeError, 'circular depdendency: Foo#two' )
    end
  end
end
# ..
end
