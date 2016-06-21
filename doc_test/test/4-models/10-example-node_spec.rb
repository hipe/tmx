require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] models - example node" do

    TS_[ self ]
    use :memoizer_methods

    context "(context)" do

      it "loads"  do
        _subject_module
      end

      shared_subject :_widget_subject_instance do

        _build_subject_instance_via_these_runs_and_choices(
          _same_discussion_run,
          _same_code_run,
          __widget_choices,
        )
      end

      shared_subject :_real_subject_instance do

        _build_subject_instance_via_these_runs_and_choices(
          _same_discussion_run,
          _same_code_run,
          __real_choices,
        )
      end

      it "builds (widget)" do
        _widget_subject_instance or fail
      end

      it "builds (real)" do
        _real_subject_instance or fail
      end

      it "wahoootey (widget)" do

        _expect_big_string _widget_subject_instance, <<-HERE.unindent
          def test_case_smooth_mamma_jamma
            code line w/o ting ting
            some( thing ).must eql :thang
          end
        HERE
      end

      it "wahoootey (real)" do

        _expect_big_string _real_subject_instance, <<-HERE.unindent
          it "smooth mamma jamma" do
            code line w/o ting ting
            some( thing ).should eql :thang
          end
        HERE
      end

      shared_subject :_same_discussion_run do

        _disucssion_run_via_big_string <<-HERE.unindent
          # matchu pitchu no see
          # it smooth mamma jamma:
        HERE
      end

      shared_subject :_same_code_run do

        _code_run_via_big_string <<-HERE.unindent
          #     code line w/o ting ting
          #     some( thing )  # => :thang
        HERE
      end

      def __widget_choices
        TS_::FixtureOutputAdapters::Widget.choices_instance___
      end

      def __real_choices
        o = Home_::OutputAdapters_::Quickie.begin_choices
        o.init_default_choices
        o
      end
    end

    def _expect_big_string subject_instance, big_exp_s

      TestSupport_::Expect_Line::Streams_have_same_content.call(
        subject_instance.to_line_stream,
        line_stream_via_string_( big_exp_s ),
        self,
      )
    end

    def _build_subject_instance_via_these_runs_and_choices d_r, c_r, cx
      _subject_module.via_runs_and_choices__ d_r, c_r, cx
    end

    def _disucssion_run_via_big_string s
      TS_::Runs::Discussion_run_via_big_string[ s ]
    end

    def _code_run_via_big_string s
      TS_::Runs::Code_run_via_big_string[ s ]
    end

    def _subject_module
      models_module_::ExampleNode
    end
  end
end
