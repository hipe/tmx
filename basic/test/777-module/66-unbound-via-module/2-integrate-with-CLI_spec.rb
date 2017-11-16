require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] module - as - unbound: integrate w/ CLI" do

    TS_[ self ]
    use :want_CLI
    use :module_as_unbound

    it "1.4 - help" do

      invoke '-h'

      _s = flush_to_unstyled_string_contiguous_lines_on_stream :e
      _s.should match %r(
        \b
        node-one-which-is-module
        [[:space:]]+
        node-two-which-is-class
        [[:space:]]+
        node-four-which-is-function$
      )x

      want_no_more_lines
      want_result_for_success
    end

    it "0 - (missing required arg) reflects well" do

      invoke 'node-four-which-is-function'
      want :styled, :e, /\Aexpecting <arg1>\z/
      want :styled, :e, /\Ausage: bsc node-four-which-is-function <arg1>\z/
      want_result_for_failure
    end

    it "1.3 - good arg" do

      invoke 'node-four-which-is-function', 'hi'
      want :styled, :e, "yay wahoo: hi"
      want :o, "(4 says: pong: hi)"
      want_no_more_lines
      want_result_for_success
    end

    def subject_CLI
      Home_.lib_.brazen::CLI
    end

    def get_invocation_strings_for_want_stdout_stderr
      [ 'bsc' ]
    end

    def CLI_options_for_want_stdout_stderr
      [ :back_kernel, kernel_one_ ]
    end
  end
end
