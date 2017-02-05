module Skylab::TestSupport

  module Quickie

    class Plugins::Tag

      def initialize
      end

      if false
      def initialize adapter
        @adapter = adapter
        @sw = adapter.build_required_arg_switch FLAG__
        @y = adapter.y
      end

      FLAG__ = '-tag'.freeze

      def opts_moniker
      end

      def args_moniker
        ARGS_MONIKER__
      end
      ARGS_MONIKER__ = "#{ FLAG__ }=<tag>"
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "passes through to the test runner."
      end

      if false
      def prepare sig
        @sig = sig
        @_d_a = @sw.any_several_indexes_in_input @sig
        @result_of_prepare = nil
        if @_d_a
          __via_d_a_prepare
        end
        @result_of_prepare
      end

      def culled_test_files_eventpoint_notify
        @adapter.add_iambic [ :tag, * @o_a ]
        NIL_
      end

      def __via_d_a_prepare
        @o_a = []
        @_d_a.each do |d|
          @s = @sig.input[ d ][ @sw.s.length + 1 .. -1 ]
          if @s.length.zero?
            @y << "#{ _flag } must have an argument"
            @o_a = nil
            break
          else
            ___via_s_parse
            @o_a or break
          end
        end
        if @o_a
          __accept_args_and_activate_plugin
        end
        NIL_
      end

      def ___via_s_parse
        md = TAG_RX___.match @s
        if md
          ___parse_tag( * md.captures )
        else
          @y << "#{ _flag } must be a valid tag (had: \"#{ @s }\")"
          @o_a = nil
        end ; nil
      end

      TAG_RX___ = /\A(~)?([_a-zA-Z][_a-zA-Z0-9]*)(:.+)?\z/

      def _flag
        FLAG__
      end

      def ___parse_tag not_, tag, asst
        @o_a.push "#{ not_ }#{ tag }#{ asst }"
        NIL_
      end

      def __accept_args_and_activate_plugin
        @_d_a.each do |d|
          @sig.nilify_input_element_at_index d
        end
        @sig.rely :CULLED_TEST_FILES
        @result_of_prepare = @sig ; nil
      end
      end
    end
  end
end
