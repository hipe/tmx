module Skylab::Snag

  class Models_::Node_Collection

    class Actions::Digraph

      if false

    desc "write to STDOUT a digraph of the ##{}doc-node's"

      def init
        @fillcolor = '#b5d5fb'
        @fontname = 'Helvetica-Narrow'
        @label = '\\N'
        @penwidth = '1.1566'
        @shape = 'Mrecord'
        @style = 'filled'
      end
      NODE_ATTR_I_A__ = [ :fillcolor, :fontname, :label,
        :penwidth, :shape, :style ]


      attr_writer :path

      def execute
        ok = output_opening
        ok &&= output_body
        ok && output_closing
      end

    private

      def output_opening
        send_payload_line 'digraph {'
        @path and output_label
        output_prototype_node
      end

      def output_label
        send_payload_line "label=\"docs for #{ esc @path }\""
      end

      def output_prototype_node
        _a = NODE_ATTR_I_A__.reduce [] do |m, i|
          x = instance_variable_get :"@#{ i }"
          x or next m
          m.push "#{ i }=\"#{ esc x }\""
          m
        end
        send_payload_line "node [#{ _a * ', ' }]"
        ACHIEVED_
      end
      def esc s
        s.gsub QUOTE_, BACKSLASH_QUOTE_
      end

      def output_body
        @scn = produce_stream_for_output_body
        @scn && output_body_with_stream
      end

      def produce_stream_for_output_body
        call_API [ :doc, :digraph ],
          :on_info_line, handle_info_line,
          :on_error_event, handle_error_event,
          :working_dir, @path
      end

      def output_body_with_stream
        @oy = ::Enumerator::Yielder.new( & delegate.method( :receive_payload_line ))
        @ev = @scn.gets
        while @ev
          send @ev.terminal_channel_i
          @ev = @scn.gets
        end
        ACHIEVED_
      end

      def draw_arc
        @ev.express_into_under @oy, expression_agent ; nil
      end

      def draw_node
        node = @ev.node
        id_s = node.identifier.body_s
        s = node.first_line_body
        s_ = Remove_uninteresting_hashtags__[ s ]
        s = s_
        s.strip!
        s.gsub! QUOTE_, BACKSLASH_QUOTE_
        send_payload_line "#{ id_s } [label=\"[##{ id_s }] #{ s }\"]"
        nil
      end

      def output_closing
        send_payload_line '}'
      end

      class Remove_uninteresting_hashtags__
        Snag_::Model_::Actor[ self,
          :properties, :s
        ]

        def initialize a
          super
          @scn = Snag_::Models::Hashtag.
            interpret_simple_stream_from_string( @s ).
             flush_to_puts_stream
        end
        def execute
          @y = []
          @o = @scn.gets
          while @o
            send H__.fetch @o.nonterminal_symbol
            @o = @scn.gets
          end
          @y * EMPTY_S_
        end
        H__ = { string: :process_string, hashtag: :process_hashtag }.freeze
        def process_string
          @y << @o.to_s ; nil
        end
        def process_hashtag
          _stem = @o.get_stem_string
          case _stem
          when PARENT_NODE__ ; skip_any_hashtag_value
          when DOC_NODE__ ; passthru_any_hashtag_value
          else ; passthru_hashtag
          end ; nil
        end
        DOC_NODE__ = 'doc-node' ; PARENT_NODE__ = 'parent-node'.freeze
        def passthru_hashtag
          @y << @o.to_s
          passthru_any_hashtag_value
        end
        def passthru_any_hashtag_value
          with_any_value -> { @y << @scn.gets.to_s }
        end
        def skip_any_hashtag_value
          with_any_value -> { @scn.advance_one }
        end
        def with_any_value p
          if o = @scn.peek and :hashtag_name_value_separator == o.nonterminal_symbol
            p[]
            if o = @scn.peek and :hashtag_value == o.nonterminal_symbol
              p[]
            end
          end ; nil
        end
      end

      QUOTE_ = '"'.freeze ; BACKSLASH_QUOTE_ = '\\"'.freeze

      end
    end
  end
end
