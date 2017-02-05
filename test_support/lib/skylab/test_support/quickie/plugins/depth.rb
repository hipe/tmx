module Skylab::TestSupport

  module Quickie

    class Plugins::Depth

      def initialize
      end

      if false
      def initialize adapter
        @adapter = adapter
        @sw = adapter.build_required_arg_switch FLAG__
        @y = adapter.y
      end
      end

      FLAG__ = '-depth'.freeze

      if false
      def opts_moniker
      end

      def args_moniker
        ARGS_MONIKER__
      end
      ARGS_MONIKER__ = "#{ FLAG__ }=<[M-]N>"
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "only operate on spec files at depths M thru N."
        y << "floor depth M defaults to N. a spec file's depth"
        y << "is how deep its filesystem path is (in terms of"
        y << "nested directories) relative to the \"shallowest\""
        y << "spec file(s) which we designate as having a depth"
        y << "of 1. e.g \"#{ flg }=2..3\" says \"operate on all"
        y << "spec files at depths 2 and 3, but none at depth 1"
        y << "nor at depth 4 or deeper. useful for working thru"
        y << "a test-suite one layer at a time."
      end

      if false
      def prepare sig
        @sig = sig
        @idx = @sw.any_first_index_in_input @sig
        @result_of_prepare = nil
        @idx && via_idx_prepare
        @result_of_prepare
      end

    private

      def via_idx_prepare
        @arg = @sig.input[ @idx ][ @sw.s.length + 1 .. -1 ]
        if @arg.length.nonzero?
          parse_argument
        else
          @y << "#{ flg } must have an argument"
        end ; nil
      end

      def parse_argument
        md = RANGE_RX__.match @arg
        if md
          parse_range( * md.captures )
        else
          @y << "#{ flg } must be an integer or range (had: \"#{ @arg }\")"
        end ; nil
      end
      _DIGIT_ = '-?[0-9]+'
      RANGE_RX__ = /\A
        (?: (?<min>#{ _DIGIT_ })  (?:-|\.\.)   )?
        (?<max>#{ _DIGIT_ })
      \z/x

      def parse_range min_s, max_s
        max = max_s.to_i
        min = min_s ? min_s.to_i : max
        if 0 > min
          @y << "#{ flg } min must be non-negative (had: #{ min })"
        elsif 0 > max
          @y << "#{ flg } max must be non-negative (had: #{ max })"
        elsif min > max
          @y << "#{ flg } min must be less than or equal to max #{
            }(min: #{ min }, max: #{ max })"
        else
          @range = ::Range.new min, max
          accpt_args_and_activate_plugin
          @result_of_prepare = @sig
        end ; nil
      end

      def accpt_args_and_activate_plugin
        @sig.nilify_input_element_at_index @idx
        @sig.carry :TEST_FILES, :CULLED_TEST_FILES
        NIL_
      end

      def test_files_eventpoint_notify

        if @range.end.zero?
          when_depth_zero
        else

          a = _services.get_test_path_array

          if a.length.zero?
            when_no_test_files
          else
            first_pass a
            second_pass
          end
        end
      end

      def when_no_test_files
        @y << "(#{ flg } will have no effect because there are no spec files.)"
        ACHIEVED_
      end

      def when_depth_zero
        @y << "(\"#{ flg }=0\" always filters out all spec files.)"
        replace_list_with EMPTY_A_
      end

      def first_pass a
        min = nil ; max = nil
        check_min = -> d do
          min = d
          check_min = -> d_ do
            min > d_ and min = d_ ; nil
          end ; nil
        end
        check_max = -> d do
          max = d
          check_max = -> d_ do
            max < d_ and max = d_ ; nil
          end ; nil
        end
        a.map! do |path_s|
          d = 0 ; count = 0
          while (( d_ = path_s.index ::File::SEPARATOR, d ))
            count += 1
            d = d_ + 1
          end
          check_min[ count ] ; check_max[ count ]
          Entry__.new count, path_s
        end
        @min = min ; @max = max ; @entry_a = a ; nil
      end

      Entry__ = ::Struct.new :raw_depth_d, :path_s

      def second_pass
        raw_floor = @range.begin + @min - 1
        raw_ceiling = @range.end + @min - 1
        num_too_shallow = num_too_deep = 0
        path_s_a = @entry_a.reduce [] do |m, x|
          raw_d = x.raw_depth_d
          if raw_ceiling < raw_d
            num_too_deep += 1
          elsif raw_floor > raw_d
            num_too_shallow += 1
          else
            m.push x.path_s
          end ; m
        end
        report num_too_shallow, num_too_deep, raw_floor, raw_ceiling
        act num_too_shallow + num_too_deep, path_s_a
      end

      def report lo, hi, lo_, hi_  # :+[#hu-002]
        s_p_a = nil
        noun = -> d do
          r = "#{ d } spec file#{ 's' if 1 != d }"
          noun = -> d_ { "#{ d_ }" } ; r
        end
        noun_ = -> do
          r = "raw depth" ; noun_ = -> { "depth" } ; r
        end
        its = -> d do
          1 == d ? 'its' : 'their'
        end
        if lo.nonzero?
          ( s_p_a ||= [] ).push -> do
            "#{ noun[ lo ] } because of #{ its[ lo ] } #{ noun_[] } #{
             }less than #{ lo_ }"
          end
        end
        if hi.nonzero?
          ( s_p_a ||= [] ).push -> do
            "#{ noun[ hi ] } because of #{ its[ hi ] } #{ noun_[] } #{
             }greater than #{ hi_ }"
          end
        end
        if s_p_a
          _s_a = s_p_a.map( & :call )
          @y << "(filtering out #{ _s_a * ' and ' }.)"
        else
          report_nothing_was_filtered
        end ; nil
      end

      def report_nothing_was_filtered
        @y << "#{ ick_arg } filters nothing out. please omit this flag."
        NIL_
      end

      def act num_filtered_out, path_s_a
        if num_filtered_out.zero?
          when_nothing_was_filtered
        elsif path_s_a.length.zero?
          when_everything_was_filtered
        else
          replace_list_with path_s_a
        end
      end

      def when_nothing_was_filtered
        UNABLE_  # "CEASE_"
      end

      def when_everything_was_filtered
        report_everything_was_filtered
        _services.replace_test_path_s_a EMPTY_A_
        ACHIEVED_
      end

      def report_everything_was_filtered
        @y << "#{ ick_arg } filters out every spec file. #{
         }nothing to do."
      end

      def replace_list_with path_s_a
        _services.replace_test_path_s_a path_s_a
        ACHIEVED_
      end

      def ick_arg
        "\"#{ flg }=#{ @range }\""
      end
      end

      def flg
        FLAG__
      end

      if false
      def _services
        @adapter.services
      end
      end  # if false
    end
  end
end
