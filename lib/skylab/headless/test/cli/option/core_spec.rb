require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Option

  describe "[hl] CLI::Option__" do

    it "`basic_switch_index_curry` is a hack to see if a basic switch is present" do
      p = Subject_[].basic_switch_index_curry '--foom'
      p[ [ 'abc' ] ].should eql nil
      p[ [ 'abc', '--fo', 'def' ] ].should eql 1
      p[ [ '--foomer', '-fap', '-f', '--foom' ] ].should eql 2
    end
  end
end
