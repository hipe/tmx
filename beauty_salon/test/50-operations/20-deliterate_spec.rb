require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] operations - deliterate' do

    TS_[ self ]
    use :my_API

    context 'bad range (first term)' do

      it 'fails' do
        _tuple || fail
      end

      it 'line (NOTE still needs legacy expag)' do
        _ev = _tuple.first
        _actual_s = black_and_white _ev
        _actual_s ==
          "'from-line' must be greater than or equal to 1, had -1" or fail
      end

      shared_subject :_tuple do

        _call_from_to( -1, 2 )

        _tuple_via_expecting_this_one_error :invalid_property_value
      end
    end

    context 'bad range (second term) - epic error message' do

      it 'fails' do
        _tuple || fail
      end

      it 'line' do

        _ev = _tuple.first

        _actual_s = black_and_white _ev

        _actual_s == (
          "'to-line' must be -1 or greater than or equal to 1. had -2"
        ) || fail
      end

      shared_subject :_tuple do

        _call_from_to 1, -2

        _tuple_via_expecting_this_one_error :not_in_range
      end
    end

    context 'bad range (relative)' do

      it 'fails' do
        _tuple || fail
      end

      it 'line' do

        _actual_lines = _tuple.first

        _actual_lines == [
          "'to-line' (2) cannot be less than 'from-line' (3)"
        ] || fail
      end

      shared_subject :_tuple do

        _call_from_to 3, 2

        _tuple_via_expecting_this_one_error :expression, :upside_down_range
      end
    end

    context 'work' do

      it 'hi' do
        _tuple || fail
      end

      it 'code stripped of comments is output to STDOUT' do

        _actual = _tuple.first
        want_these_lines_in_array_with_trailing_newlines_ _actual do |y|
          y << 'wowza'
          y << 'nowza'
          y << 'gowza'
        end
      end

      it 'the comments that were stripped are output to STDERR' do

        _actual = _tuple[1]
        want_these_lines_in_array_ _actual do |y|
          y << 'commentie'
          y << 'fommentie'
        end
      end

      shared_subject :_tuple do

        _line_st = Home_.lib_.basic::String::LineStream_via_String[ <<~HERE ]
        howza
        wowza # commentie
        nowza
        gowza # fommentie
        lowza # zomentie
        bowza

      HERE
        __flush_tuple_via_expecting_success _line_st
      end

      def __flush_tuple_via_expecting_success line_st

        sout = _new_local_spy :sout
        serr = _new_local_spy :serr

        call( * _subject_action,

        :comment_line_downstream, serr,
        :code_line_downstream, sout,
        :line_upstream, line_st,
        :from_line, 2,
        :to_line, 4,
      )

        want_API_result_for_success_
        [
          sout._release_array_,
          serr._release_array_,
        ]
      end
    end

    # -- assertion

    def black_and_white ev  # (copy pasted instead of bring in big lib)
      _expag = expression_agent
      ev.express_into_under "", _expag
    end

    # -- setup

    def _tuple_via_expecting_this_one_error * sym

      tuple = []

      want :error, * sym do |em_x|
        tuple.push em_x
      end

      want_API_result_for_failure_

      tuple
    end

    def _call_from_to from_d, to_d
      call( * _subject_action,
        * _dummy_args,
        :from_line, from_d,
        :to_line, to_d,
      )
    end

    def _new_local_spy sym
      X_opdel_Spy.new sym, self
    end

    memoize :_dummy_args do
      [ :comment_line_downstream, :_x_,
        :code_line_downstream, :_xx_,
        :line_upstream, :_xxx_, ].freeze
    end

    def expression_agent
      Expression_agent_from_legacy_[]
    end

    # ==

    class X_opdel_Spy

      def initialize moniker_x, tc
        if tc.do_debug
          @debug_IO = tc.debug_IO
          @_recv = :__receive_loudly
        else
          @_recv = :_receive_normally
        end
        @moniker = moniker_x
        @array = []
      end

      def << s
        send @_recv, s
      end

      def __receive_loudly s
        @debug_IO.puts "#{ @moniker }: #{ s }"
        _receive_normally s
      end

      def _receive_normally s
        @array.push s ; nil
      end

      def _release_array_
        remove_instance_variable( :@array ).freeze
      end
    end

    def _subject_action
      :deliterate
    end
  end
end
# #history-A.1: full rewrite during wean off [br]
