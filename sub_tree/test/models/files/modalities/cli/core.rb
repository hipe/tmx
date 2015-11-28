module Skylab::SubTree::TestSupport

  module Models::Files::Modalities::CLI

    def self.[] tcc
      tcc.include self
    end

    _ = TS_.lib_ :modality_integrations_CLI_expect_expression

    include _.instance_methods_module__

    # ~ ad-hoc DSL (for one file currently)

    def with str
      _unindent str
      @paths_string = str
      nil
    end

    def make expect_str

      io = Home_::Library_::StringIO.new @paths_string
      io.rewind
      @stdin_for_expect_stdout_stderr = io
      local_invoke

      _unindent expect_str
      flush_to_string_contiguous_lines_on_stream( :o ).should eql expect_str

      expect_succeeded
    end

    def _unindent str
      str.unindent
      nil
    end

    def local_invoke * argv
      argv.unshift 'files'
      using_expect_stdout_stderr_invoke_via_argv argv
    end

    # ~ #hook-outs

    def subject_CLI
      Home_::CLI
    end

    define_method :invocation_strings_for_expect_stdout_stderr, -> do
      a = [ 'stflz' ].freeze
      -> do
        a
      end
    end.call
  end
end
