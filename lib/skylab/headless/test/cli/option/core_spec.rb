require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Option

  describe "[hl] CLI option" do
    context "hack to see if a basic switch is present" do
      Sandbox_1 = Sandboxer.spawn
      it "like this" do
        Sandbox_1.with self
        module Sandbox_1
          p = Subject_[].basic_switch_index_curry '--foom'
          p[ [ 'abc' ] ].should eql( nil )
          p[ [ 'abc', '--fo', 'def' ] ].should eql( 1 )
          p[ [ '--foomer', '-fap', '-f', '--foom' ] ].should eql( 2 )
        end
      end
    end
  end
end
