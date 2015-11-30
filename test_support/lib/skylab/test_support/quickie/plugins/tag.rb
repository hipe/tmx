module Skylab::TestSupport

  module Quickie

    class Plugins::Tag

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

      def desc y
        y << "passes through to the test runner."
      end

      def prepare sig
        @sig = sig
        @d_a = @sw.any_several_indexes_in_input @sig
        @result_of_prepare = nil
        @d_a && via_d_a_prepare
        @result_of_prepare
      end

      def culled_test_files_eventpoint_notify
        @adapter.add_iambic [ :tag, * @o_a ]
        NIL_
      end

    private

      def via_d_a_prepare
        @o_a = []
        @d_a.each do |d|
          @s = @sig.input[ d ][ @sw.s.length + 1 .. -1 ]
          if @s.length.zero?
            @y << "#{ flg } must have an argument"
            @o_a = nil
            break
          else
            via_s_parse
            @o_a or break
          end
        end
        @o_a and accpt_args_and_activate_plugin ; nil
      end

      def via_s_parse
        md = TAG_RX__.match @s
        if md
          parse_tag( * md.captures )
        else
          @y << "#{ flg } must be a valid tag (had: \"#{ @s }\")"
          @o_a = nil
        end ; nil
      end
      TAG_RX__ = /\A(~)?([_a-zA-Z][_a-zA-Z0-9]*)(:.+)?\z/

      def parse_tag not_, tag, asst
        @o_a.push "#{ not_ }#{ tag }#{ asst }" ; nil
      end

      def accpt_args_and_activate_plugin
        @d_a.each do |d|
          @sig.nilify_input_element_at_index d
        end
        @sig.rely :CULLED_TEST_FILES
        @result_of_prepare = @sig ; nil
      end

      def flg
        FLAG__
      end
    end
  end
end
