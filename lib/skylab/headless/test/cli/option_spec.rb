require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Option

  ::Skylab::Headless::TestSupport::CLI[ self ]

  include CONSTANTS

  Headless = ::Skylab::Headless

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Headless::CLI::Option" do  # NOTE this is a generated file
    context "hack to see if a basic switch is present" do
      Sandbox_1 = Sandboxer.spawn
      it "like this" do
        Sandbox_1.with self
        module Sandbox_1
          P = Headless::CLI::Option::FUN.basic_switch_index_curry[ '--foom' ]
          P[ [ 'abc' ] ].should eql( nil )
          P[ [ 'abc', '--fo', 'def' ] ].should eql( 1 )
          P[ [ '--foomer', '-fap', '-f', '--foom' ] ].should eql( 2 )
        end
      end
    end
  end
end
