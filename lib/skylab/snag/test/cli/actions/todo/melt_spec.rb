require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI::Actions

  describe "[sg] CLI actions melt" do

    extend TS_

    with_invocation 'todo', 'melt'

    context "when no todo's are found" do

      with_tmpdir do |o|
        o.clear.write 'foo.source-code', <<-O.unindent
          there is no todo here
        O
      end

      it "awesome awesome awesome self-describing find structure" do
        invoke '--name', '*.source-code', '.'
        expect :info, %r(\Awhile melting todos, found no todo's in \. #{
          }named \*\.source-code with the pattern \[@#\]todo\\>\z)
        expect_succeeded
      end
    end

    context "with a plain old ##{}todo after a line, with no message" do

      with_tmpdir do |o|
        o.clear.write 'jerbis.source-code', <<-O.unindent
          alpha
          beta ##{}todo
          gamma
        O
        nil
      end

      msg = 'will not melt todo with no message'

      it " - #{ msg }" do
        invoke '--name', '*.source-code', '.'
        expect :info, /#{ msg }/
      end
    end

    context "but with one file, with one such line" do

      with_tmpdir do |td|
        td.clear

        @source_pn = td.write 'jeebis.sc', <<-O.unindent
          aleph
          bet ##{}todo we should fix this
          gimmel
        O

        @manifest_pn = td.write manifest_file, <<-O.unindent
          [#002]       i started at two just to be cute
        O

        Skylab::Snag::API::Client.setup -> client do
          client.max_num_dirs_to_search_for_manifest_file = 1  # #open [#050]
        end
      end

      it "ADDS LINE TO MANIFEST AND CHANGES SOURCE CODE LINE" do
        invoke '--name', '*.sc', '.'
        output.lines.last.string.should match(
          %r{changed 1 line in \./jeebis\.sc.+we should fix this} )
        @manifest_pn.read.should eql( <<-O.unindent )
          [#003] #open we should fix this
          [#002]       i started at two just to be cute
        O
        @source_pn.read.should eql( <<-O.unindent )
          aleph
          bet  # #open [#003] - we should fix this
          gimmel
        O
      end
    end
  end
end
