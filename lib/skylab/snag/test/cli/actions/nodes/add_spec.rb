require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI::Actions

  describe "[sg] CLI actions nodes add" do

    extend TS_

    with_invocation 'nodes', 'add'

    with_tmpdir_patch do

      <<-O.unindent
        diff --git a/#{ manifest_path } b/#{ manifest_path }
        --- /dev/null
        +++ b/#{ manifest_path }
        @@ -0,0 +1,4 @@
        +[#003] #open feep my deep
        +[#002]       #done wizzle bizzle 2013-11-11
        +               one more line
        +[#001]       #done
      O
    end

    it "verbose dry run" do
      setup_tmpdir_read_only
      invoke '-n', '-v', 'foo bizzle'

      o( / new line: / )
      if output.lines.first.string =~ /mkdir .+snag-PROD/ # [#033]
        output.lines.shift
      elsif output.lines.first.string =~ / rm /
        output.lines.shift
      end
      o( / mv /)
      o( / mv /)
      o( / done\./ )
      o
    end

    it "non-verbose non-dry run" do
      invoke 'foo bizzle'
      o( /new line: \[#004\] {7}foo bizzle$/ )
      o( /\bdone\./ )
      o
    end
  end
end
