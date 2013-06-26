require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Regret::API::Actions::DocTest

  ::Skylab::TestSupport::TestSupport::Regret::API::Actions[ DocTest_TestSupport = self ]

  include CONSTANTS

  TestSupport = ::Skylab::TestSupport  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::TestSupport::Regret::API::Actions::DocTest" do
    context "basic usage" do
      Sandbox_1 = Sandboxer.spawn
      it "basic usage" do
        Sandbox_1.with self
        module Sandbox_1
          class Foo
            def bar
              :yes
            end
          end

          Foo.new.bar.should eql( :yes )
        end
      end
    end
    context "more advanced usage" do
      Sandbox_2 = Sandboxer.spawn
      it "more advanced usage" do
        Sandbox_2.with self
        module Sandbox_2
          class Foo
          end
          -> do
            Foo.new.wat
          end.should raise_error( NoMethodError,
                       ::Regexp.new( "\\Aundefined\\ method\\ `wat'" ) )
        end
      end
    end
  end
end
