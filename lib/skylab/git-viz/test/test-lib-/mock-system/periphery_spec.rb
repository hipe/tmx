require_relative 'test-support'

module Skylab::GitViz::TestSupport::Test_Lib_::Mock_System

  describe "[gv] mock system periphery (different kinds of strange behavior)", zmq: true do

    extend TS__ ; use :server_expect

    context "strange parameter" do

      it "the server returns one error statement" do
        @response = mani.process_strings %w(--strange fiz faz)
        expect :error, %r(\Ainvalid option: --strange\z)
        expect_errored
      end
    end

    context "strange manifest path" do

      it "the server returns an echo of the request and an error statement" do
        execute
        expect_that_the_request_string_was_echoed
        expect :error, /\ANo such file or directory\b.+\bnot-exist\.manif/
        expect_errored
      end

      def get_manifest_path
        GitViz.dir_pathname.join( 'not-exist.manifest' ).to_path
      end
    end

    context "empty manifest file (zero bytes)" do

      it "one echo and one error statement" do
        expect_response_pattern_for_no_entries
      end

      def manifest_prefix_pathname
        test_support_prefix_pathname
      end

      def manifest_suffix
        'zero-bytes.file'
      end
    end

    context "empty manifest file (one byte)" do

      it "one echo and one error statement" do
        expect_response_pattern_for_no_entries
      end

      def manifest_prefix_pathname
        test_support_prefix_pathname
      end

      def manifest_suffix
        'zero-bytes.file'
      end
    end

    context "strange property in a manifest entry" do

      it "the server returns an echo and then a structured error statement" do
        execute
        expect_that_the_request_string_was_echoed
        expect :error, :iambic, :manifest_parse, :unexpected_term_parse_error
        expect_errored( GitViz::Test_Lib_::
          Mock_System::Fixture_Server::MANIFEST_PARSE_ERROR_ )
      end

      let :manifest_suffix do
        'multiline-and-comments-and-dynamic-error-handling.manifest'
      end
    end

    let :mani do
      GitViz::Test_Lib_::
        Mock_System::Fixture_Server::Responder__.new stderr_yielder
    end

    let :stderr_yielder do
      @stderr_lines = []
      ::Enumerator::Yielder.new do |msg|
        if do_debug
          debug_IO.puts msg.inspect
        end
        @stderr_lines << msg ; self
      end
    end

    # ~ execution phase

    def execute
      @mani_path = get_manifest_path
      @response = mani.process_strings [ '--mani', @mani_path, * other_args ]
      nil
    end

    def get_manifest_path
      manifest_prefix_pathname.join( manifest_suffix ).to_path
    end

    def manifest_prefix_pathname
      TS__::Fixtures.dir_pathname
    end

    def other_args
      OTHER_ARGS__
    end
    OTHER_ARGS__ = %w( --ch x --co ^va ).freeze

    # ~ assertion phase

    def expect_that_the_request_string_was_echoed
      expect :info, :iambic, :argv_tail
    end

    def expect_response_pattern_for_no_entries
      execute
      expect_that_the_request_string_was_echoed
      expect_no_entries_statement_about @mani_path
      expect_errored
    end

    def expect_no_entries_statement_about path
      expect :error, %r(\Ano entries in manifest file, all queries #{
        }destined to fail - #{ ::Regexp.escape path }\z)
    end

    def expect_no_commands_found
      expect :notice, /\Ano commands were found matching the above query\.\z/
    end

    def test_support_prefix_pathname
      TestSupport::Data::Universal_Fixtures.dir_pathname
    end
  end
end
