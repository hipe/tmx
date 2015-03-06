require_relative '../../test-support'

module Skylab::SubTree::TestSupport::Models_Files::The_CLI_Modality

  ::Skylab::SubTree::TestSupport::Models_Files[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  SubTree_ = SubTree_

  module InstanceMethods

    include SubTree_::TestSupport::Modality_Integrations::CLI::Expect_expression::Instance_Methods

    define_method :expect, instance_method( :expect )  # because rspec

    # ~ ad-hoc DSL (for one file currently)

    def with str
      _unindent str
      @paths_string = str
      nil
    end

    def make expect_str

      io = SubTree_::Library_::StringIO.new @paths_string
      io.rewind
      @use_this_as_stdin = io
      local_invoke

      _unindent expect_str
      get_string_for_contiguous_lines_on_stream( :o ).should eql expect_str

      expect_succeeded
    end

    def _unindent str
      str.unindent
      nil
    end

    def local_invoke * argv
      argv.unshift 'files'
      invoke_via_argv argv
    end

    # ~ #hook-outs

    def subject_CLI
      SubTree_::CLI
    end

    define_method :invocation_strings_for_expect_expression, -> do
      a = [ 'stflz' ].freeze
      -> do
        a
      end
    end.call
  end
end
