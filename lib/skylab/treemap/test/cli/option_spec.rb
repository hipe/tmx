require_relative 'test-support'

module Skylab::Treemap::TestSupport::CLI

  # Quickie.

  describe "#{ Treemap }::CLI - the most ridoncunculous #{
    }false requirements EVAR.." do

    extend CLI_TestSupport

    num_streams 3

    it "`render -r` - CHECK THIS SHIZ OUT - help is dynamic - (superlock)" do
      client.invoke ['render', '-h']
      styld( /^usage: nerkiss render .*\[-c <CHAR>\]/ )
      white
      styld( /^description: .*treemap/ )
      white
      styld( /^options:/ )
      serrs.shift.should match( /-a\b.*--adapter <NAME>[ ]*which.+adapter/ )
      styled( serrs.shift.strip ).should eql(
        '(known adapters are foo_bar and r) (default: r)' )
    end

    it "help for specific adapter, adapter not found" do
      client.invoke [ 'render', '-h', '-a', 'twerk' ]
      styld( /adapter "twerk" not found.+known adapters are.+\band\b/i )
      styld( /^usage:/i )
      styled( serrs.shift ).downcase.should be_include( "use nerkiss render #{
        }-h for help about render help for a particular adapter" )
    end

    it "help for a specific adapter, adapter doesn't have that action" do
      client.invoke [ 'render', '-h', '-a', 'foo' ]
      serrs.shift.should match( /foo-bar has no such CLI action - render/i )
      styled( serrs.last ).should be_include( 'particular' )
    end

    it "THE ADAPTER LOADS ADAPTER SPECIFIC NERKS INTO THE HELP SCREEN" do
      client.invoke [ 'render', '-h', '-a', 'r' ]
      tail = []
      loop do
        line = serrs.pop or break
        tail << line
        '' == line and break
      end  # (note tail is in reverse order now, e.g. the last 3 lines)
      tail.pop.should eql( '' )
      styled( tail.pop ).should match( /r-specific-options/ )
      ( 1..4 ).should be_include( tail.length )
      tail.grep( /output.+r.script/i ).length.should eql( 1 )
    end
  end
end
