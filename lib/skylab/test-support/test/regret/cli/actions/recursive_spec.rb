require_relative '../../test-support'

module Skylab::TestSupport::TestSupport::Regret::CLI::Actions::Recursiv

  TestSupport_ = ::Skylab::TestSupport

  parent = ::Skylab::TestSupport::TestSupport::Regret::CLI::Actions

  @dir_pathname = parent.dir_pathname.join 'recursive'

  _Face_TS = TestSupport_::Lib_::Face__[]::TestSupport
  _Face_TS::CLI::Client[ self ]

  parent[ TS__ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  describe "[ts] regret CLI actions recursive" do

    extend TS__

    def client_class
      TestSupport_::Regret::CLI::Client
    end

    def cd_and_invoke *argv
      r = nil
      TestSupport_::Library_::FileUtils.cd TestSupport_.dir_pathname.to_s do
        r = invoke_subcmd( * argv )
      end
      r
    end

    def invoke_subcmd * argv
      invoke 'doc-test', * argv
    end

    it "outputs the lines" do
      r = cd_and_invoke '--recursive', 'list', 'regret'
      stdout_gets.should eql( "./regret/api/actions/doc-test.rb" )
      stdout_gets.should eql( "./regret/api/actions/doc-test/specer--.rb" )
      stderr_lines.should eql TestSupport_::EMPTY_A_
      r.should eql( true )
    end

    it "does the dry run that generates fake bytes omg" do
      r = cd_and_invoke '-rn', 'regret', '-f'
      str = stderr_gets
      str.should eql( '<<< ./regret/api/actions/doc-test.rb .. done.' )
      stderr_gets.should match( %r{\A>>> \./test/regret/api/#{
        }actions/doc-test_spec\.rb written \(\d\d\d+ fake bytes\)\.\z} )
      left = stderr_lines.length
      ( left % 2 ).should eql( 0 )
      ( 2..6 ).include?( left ).should eql( true )
      r.should eql( true )
    end

    it "cannot combine -r with other non-r-related sub-options" do
      r = invoke_subcmd '-rv'
      line = stderr_gets
      line.should match( /did not recognize "-v" as a valid argument to/ )
      line.should match( /expected .+ or "--"/ )
      line.should match( /if you intended .+ use "--"/ )
      r.should eql( nil )
    end

    it "requires force to overwrite (BUGGY BEHAVIOR LOCKED DOWN)" do
      cd_and_invoke '-r', './regret/api/actions/doc-test.rb'
      stderr_gets.should match( /won't overwrite without force -#{
        }.+doc-test_spec.rb/ )
      content = unstyle_styled( stderr_gets )
      content.should match( /try wtvr -h recursive for help/i )
        # because of the `change_command` hack, this reports what to
        # the surface should be a non-existant command, but meh.
    end
  end
end
