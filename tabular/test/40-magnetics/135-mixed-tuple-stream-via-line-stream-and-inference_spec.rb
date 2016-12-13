require_relative '../test-support'

module Skylab::Tabular::TestSupport

  describe "[tab] magnetics - mixed tuple strem via line stream and inference" do

    TS_[ self ]
    # use :memoizer_methods
    use :magnetics_for_infer_table

    it "loads" do
      _subject_module || fail
    end

    it "simple strings, numbers" do

      _init_stream_against_these_lines(
        "aaa  111",
        "bbb  222",
      )

      _expect_these_mixed_tuples do |y|
        y.yield "aaa", 111
        y.yield "bbb", 222
      end
    end

    it "negatives regression" do

      _init_stream_against_these_lines(
        " -55    \r",
      )

      _expect_these_mixed_tuples do |y|
        y << -55
      end
    end

    it "floats, negatives, a variety of newlines" do

      _init_stream_against_these_lines(
        "  1.2   -33.44  \n",
        " -55     66    \r",
        " 0   00.000  \r\n",
      )

      _expect_these_mixed_tuples do |y|
        y.yield 1.2, -33.44
        y.yield( -55, 66 )
        y.yield 0, 0.0
      end
    end

    it "booleans (mixed case OK)" do

      _init_stream_against_these_lines(
        "true false",
        "TRue faLSE",
        "yEs nO",
      )

      _expect_these_mixed_tuples do |y|
        y.yield true, false
        y.yield true, false
        y.yield true, false
      end
    end

    it "simple double quote, simple single quote" do

      _init_stream_against_these_lines(
        '"double quotes"',
        "'single quotes'",
      )

      _expect_these_mixed_tuples do |y|
        y << 'double quotes'
        y << 'single quotes'
      end
    end

    it "unclosed - fails" do

      spy = _begin_failure_spy_via_lines(
        '3 "double quo',
      )

      spy.expect :error, :expression, :parse_error, :non_terminated_quote do |y|
        y.first == 'non terminated quote? "\"double quo"' || fail
      end

      _finish_failure_spy spy
    end

    def _begin_failure_spy_via_lines * lines

      spy = Common_.test_support::Expect_Emission_Fail_Early::Spy.new

      spy.call_by do |x|

        _line_upstream = Stream_[ lines ]

        _st = _subject_module.call(
          _line_upstream, :_inference_not_yet_needed_, & spy.listener )

        _should_be_unable = _st.gets

        _should_be_unable  # #todo
      end

      spy
    end

    def _finish_failure_spy spy
      _x = spy.execute_under self
      _x == false || fail
    end

    def _init_stream_against_these_lines * lines

      @__mt_st = _mixed_tuple_via_lines lines
    end

    def _mixed_tuple_via_lines lines

      _line_upstream = Stream_[ lines ]

      _ = _subject_module.call( _line_upstream, :_inference_not_yet_needed_ )
      _
    end

    def _expect_these_mixed_tuples

      st = remove_instance_variable :@__mt_st

      _y = ::Enumerator::Yielder.new do |* x_a|
        mt = st.gets
        if mt
          if x_a != mt
            fail "expected #{ x_a.inspect }, had #{ mt.inspect }"
          end
        else
          fail "had none but expected #{ x_a.inspect }"
        end
      end

      yield _y

      mt = st.gets
      if mt
        fail "expected no more but had #{ mt.inspect }"
      end
    end

    def expression_agent
      the_empty_expression_agent_
    end

    def _subject_module
      mags_::MixedTupleStream_via_LineStream_and_Inference
    end
  end
end
# #born during and for "infer table"
