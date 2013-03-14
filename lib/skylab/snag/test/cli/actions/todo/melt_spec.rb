require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI::Actions

  # le Quickie.

  describe "#{ Snag::CLI } actions todo melt" do
    extend Actions_TestSupport

    invocation = [ 'todo', 'melt' ]

    define_method :invoke do |*argv|
      setup
      invoke_from_tmpdir( *invocation, *argv )
    end

    def expect name, rx
      line = output.lines.shift
      line.stream_name.should eql( name )
      line.string.should match( rx )
    end

    context "with a plain old ##{}todo after a line, with no message" do

      def setup
        @pn = tmpdir_clear.write 'jerbis.source-code', <<-O.unindent
          alpha
          beta ##{}todo
          gamma
        O
      end

      msg = 'will not melt todo with no message'

      it " - #{ msg }" do
        invoke '--name', '*.source-code', '.'
        expect :info, /#{ msg }/
      end
    end

    context "but with one file, with one such line" do

      def setup
        td = tmpdir_clear

        @source_pn = td.write 'jeebis.sc', <<-O.unindent
          aleph
          bet ##{}todo we should fix this
          gimmel
        O

        @manifest_pn = td.write manifest_path, <<-O.unindent
          [#002]       i started at two just to be cute
        O

        Skylab::Snag::API::Client.setup -> client do
          client.max_num_dirs_to_search_for_manifest_file = 1
        end
      end

      it "ADDS LINE TO MANIFEST AND CHANGES SOURCE CODE LINE" do
        invoke '--name', '*.sc', '.'
        output.lines.last.string.should match(
          %r{changed 1 line in \./jeebis\.sc.+we should fix this} )
        @manifest_pn.read.should eql( <<-O.unindent.strip )
          [#003] #open we should fix this
          [#002]       i started at two just to be cute
        O
        @source_pn.read.should eql( <<-O.unindent )
          aleph
          bet # [#003] - we should fix this
          gimmel
        O
      end
    end
  end
end
