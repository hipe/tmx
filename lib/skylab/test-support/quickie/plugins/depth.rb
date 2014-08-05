module Skylab::TestSupport

  module Quickie

    class Plugins::Depth

      def initialize svc
        @svc = svc
        @sw = svc.build_required_arg_switch FLAG__
        @y = svc.y
      end

      def flg
        FLAG__
      end

      FLAG__ = '-depth'.freeze

      def opts_moniker
      end

      def args_moniker
        ARGS_MONIKER__
      end
      ARGS_MONIKER__ = "#{ FLAG__ }=<N>"

      def desc y
        y << "only operate on spec files at depths 1..N"
        y << "depth is relative to the spec file(s) with the"
        y << "shallowest path, which of depth 1"
        nil
      end

      def prepare sig
        @sig = sig
        @idx = @sw.any_first_index_in_input @sig
        @result_of_prepare = nil
        @idx && via_idx_prepare
        @result_of_prepare
      end

      def via_idx_prepare
        @arg = @sig.input[ @idx ][ @sw.s.length + 1 .. -1 ]
        if @arg.length.nonzero?
          if /\A-?[0-9]+\z/ =~ @arg
            @depth_d = @arg.to_i
            if -1 < @depth_d
              accpt_args_and_activate_plugin
              @result_of_prepare = @sig
            else
              @y << "#{ flg } must be non-negative (had: #{ @depth_d })"
            end
          else
            @y << "#{ flg } must be an integer (had: \"#{ @arg }\")"
          end
        else
          @y << "#{ flg } must have an argument"
        end ; nil
      end

      def accpt_args_and_activate_plugin
        @sig.nilify_input_element_at_index @idx
        @sig.carry :TEST_FILES, :CULLED_TEST_FILES
        nil
      end

      def test_files_eventpoint_notify
        a = @svc.get_test_path_a
        if @depth_d.zero?
          when_depth_zero
        elsif a.length.zero?
          when_no_test_files
        else
          first_pass a
          second_pass
        end
      end

      def when_no_test_files
        @y << "(#{ flg } will have no effect because there are no spec files.)"
        PROCEDE_
      end

      def when_depth_zero
        @y << "(#{ flg }=0 always filters out all spec files.)"
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
          while (( d_ = path_s.index SEP_, d ))
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
        @too_much_depth = @depth_d + @min
        removed_count = 0
        path_s_a = @entry_a.reduce [] do |m, x|
          if @too_much_depth > x.raw_depth_d
            m.push x.path_s
          else
            removed_count += 1
            m
          end
        end
        if removed_count.zero?
          when_nothing_to_filter
        else
          @y << "(filtering out #{ removed_count } spec file(s) because #{
           }of their absolute depth greater than #{ @too_much_depth }.)"
          replace_list_with path_s_a
        end
      end

      def when_nothing_to_filter
        @y << "(nothing filtered. with #{ flg }=#{ @depth_d } and a #{
         }minimum absolute depth of #{ @min }, all spec files have paths #{
         }that fall under the absolute depth limit (#{ @too_much_depth }).)"
        PROCEDE_
      end

      def replace_list_with path_s_a
        @svc.replace_test_path_s_a path_s_a
      end
    end
  end
end
