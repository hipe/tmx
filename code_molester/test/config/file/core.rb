module Skylab::CodeMolester::TestSupport

  module Config::File

    def self.[] tcc

      tcc.extend Module_Methods___

      tcc.include self

      NIL_
    end  # >>

    module Module_Methods___

      def share_file_as_subject_  # (deprecated for next method)

        share_subject :subject do

          build_config_file_
        end
      end

      def share_file_as_config_ & p

        share_subject :config do

          x = build_config_file_
          if p
            p[ x ]
          end
          x
        end
      end
    end

    def build_config_file_

      build_config_file_with_ :path, path, :string, input_string
    end

    def build_config_file_with_ * x_a
      _build_config_file x_a
    end

    def _build_config_file x_a
      config_file_class.new_via_iambic x_a
    end

    def config_file_class
      Home_::Config::File::Model
    end

    def not_here_file_
      TestSupport_::Fixtures.file :not_here
    end

    def not_here_directory_
      TestSupport_::Fixtures.dir :not_here
    end

    def some_directory_
      TestSupport_::Fixtures.dir :empty_esque_directory
    end

    def config_is_not_valid_
      config.valid?.should eql false
    end

    def subject_invalid_reason_is_nil_
      subject.invalid_reason.should be_nil
    end

    def subject_has_no_content_items_
      subject.content_items.length.should be_zero
    end

    def unparses_losslessly_
      subject.string.should eql input_string
    end

    def read_path_ path
      ::File.open( path, ::File::RDONLY ).read
    end

    def path_does_not_exist_
      _file_exists( path ).should eql false
    end

    def path_exists_
      _file_exists( path ).should eql true
    end

    def _file_exists path
      ::File.exist? path
    end

    def black_and_white ev

      _join_with_newlines_under ev, TestLib_::Bzn[]::API.expression_agent_instance
    end

    def render_as_codified_ ev

      _expag = ::Skylab::Callback::Event.codifying_expression_agent_instance
      _join_with_newlines_under ev, _expag
    end

    def _join_with_newlines_under ev, expag

      _st = ev.to_stream_of_lines_rendered_under expag
      _st.to_a.join Home_::NEWLINE_
    end

    def parses_and_unparses_OK_

      config = self.config

      config.invalid_reason.should be_nil
      config.should be_valid

      _act = config.sexp.unparse
      _exp = input_string

      _act.should eql _exp
    end
  end
end
