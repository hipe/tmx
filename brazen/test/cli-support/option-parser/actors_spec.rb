require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - option parser - actors" do

    it "a hack to see if a basic switch looks to be present in an array" do

      p = Home_::CLI_Support::Option_Parser::Actors::Build_basic_switch_proc[ '--foom' ]
      p[ [ 'abc' ] ].should eql nil
      p[ [ 'abc', '--fo', 'def' ] ].should eql 1
      p[ [ '--foomer', '-fap', '-f', '--foom' ] ].should eql 2
    end
  end
end
