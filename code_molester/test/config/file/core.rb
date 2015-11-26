require_relative '../test-support'

module Skylab::CodeMolester::TestSupport::Config::File

  ::Skylab::CodeMolester::TestSupport::Config[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Home_ = Home_

  TestLib_ = TestLib_

  module InstanceMethods

    include Constants

    attr_reader :o

    let :subject do
      config_file_class.new_with :path, path, :string, input_string
    end

    def config
      @config ||= bld_config
    end

    def bld_config
      config_file_class.new_with :path, path, :string, content
    end

    def path
    end

    def input_string
    end

    def init_o_with * x_a
      @o = config_file_class.new_via_iambic x_a ; nil
    end

    def build_config_file_with * x_a
      config_file_class.new_via_iambic x_a
    end

    def config_file_class
      Home_::Config::File::Model
    end

    let :tmpdir do
      tmpdir = Tmpdir_instance_[]
      b = do_debug ; b_ = tmpdir.be_verbose
      if b && ! b_ or b_ && ! b
        tmpdir = tmpdir.with :be_verbose, b, :debug_IO, debug_IO
      end
      tmpdir
    end

    def parses_and_unparses_OK
      parses_OK
      unparses_OK
    end

    def parses_OK
      config.invalid_reason.should be_nil
      config.should be_valid
    end

    def unparses_OK
      sx = config.sexp
      s = sx.unparse
      s_ = content
      s.should eql s_
    end

    def black_and_white ev

      join_with_newlines_under ev, TestLib_::Bzn[]::API.expression_agent_instance
    end

    def render_as_codified ev

      _expag = ::Skylab::Callback::Event.codifying_expression_agent_instance
      join_with_newlines_under ev, _expag
    end

    def join_with_newlines_under ev, expag
      scan = ev.to_stream_of_lines_rendered_under expag
      scan.to_a.join Home_::NEWLINE_
    end
  end
end
