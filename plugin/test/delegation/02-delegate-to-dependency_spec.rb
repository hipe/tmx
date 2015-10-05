require_relative 'test-support'

module Skylab::Plugin::TestSupport::Delegation_TS

  describe "[pl] delegation - 02: delegate to dependency" do

    it "`delegate_to_dependency` is for simple, direct architectures" do

        class Base_simple_Surface
          def foo ; :FOO end
          def bar ; :BAR end
        end

        class Client_simple_Surface

          Subject_[ self ]

          delegate_to_dependency :foo, :bar

          def initialize x
            super
          end
        end

        cli = Client_simple_Surface.new Base_simple_Surface.new
        cli.foo.should eql :FOO
        cli.bar.should eql :BAR
    end
  end
end
