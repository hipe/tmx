require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI::Actions

  # this is a Quickie-compatible test - try `ruby -w` this file

  describe "#{ Snag::CLI } Actions - Add" do

    extend Actions_TestSupport

    def prepare_tmpdir
      tmpdir_clear.patch <<-HERE.unindent
        diff --git a/doc/issues.md b/doc/issues.md
        --- /dev/null
        +++ b/doc/issues.md
        @@ -0,0 +1,4 @@
        +[#003] #open feep my deep
        +[#002]       #done wizzle bizzle 2013-11-11
        +               one more line
        +[#001]       #done
      HERE
    end

    invocation = [ 'nodes', 'add' ] # how it is invoked in cli changes s/times

    it "verbose dry run" do
      prepare_tmpdir
      from_tmpdir do
        client_invoke( *invocation, '-n', '-v', 'foo bizzle' )
      end
      o( / new line: / )
      if output.lines.first.string =~ /mkdir .+snag-PROD/
        output.lines.shift # egads sorry this is bad
      elsif output.lines.first.string =~ / rm / # #todo WAT
        o( / rm / )
      end
      o( / mv /)
      o( / mv /)
      o( / done\./ )
      o
    end

    it "non-verbose non-dry run" do
      prepare_tmpdir
      from_tmpdir do
        client_invoke( *invocation, 'foo bizzle' )
      end
      o( /new line: \[#004\] {7}foo bizzle$/ )
      o( /\bdone\./ )
      o
    end
  end
end
