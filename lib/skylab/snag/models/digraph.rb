module Skylab::Snag

  module Models::Digraph

    class << self

      def shell & p
        trigger = nil
        p[ Shell__.new { |p_| trigger = p_ } ]
        trigger.call
      end
    end

    class Shell__
      def initialize
        @kernel = Kernel__.new
        yield @kernel.method :get_stream
      end
      def delegate= x
        @kernel.delegate= x
      end
      def nodes= x
        @kernel.nodes= x
      end
    end

    class Kernel__

      Snag_::Model_::Actor[ self ]

      def initialize
      end

      attr_writer :delegate, :nodes

      def get_stream
        a = produce_every_node_with_a_doc_node_tag_or_parent_node_tag
        produce_hashes_associating_every_parent_node_to_child_node a
        if @parent_h.length.zero?
          stream_when_zero_doc_nodes
        else
          @node_a = a
          stream_when_nonzero_doc_nodes
        end
      end

    private

      def produce_every_node_with_a_doc_node_tag_or_parent_node_tag
        y = [] ; scan = @nodes.all
        while (( node = scan.gets ))
          node.is_valid or next
          TAG_RX__ =~ node.first_line or next
          y.push node.collapse @delegate, :_no_API_client_
        end
        y
      end
      TAG_RX__ = /#(?:doc-(?:node|point)|parent-node)\b/  # ick, an optimization

      def produce_hashes_associating_every_parent_node_to_child_node a
        @parent_h = {} ; @child_h = {}
        a.each do |node|
          node.tags.each do |tag|
            case tag.stem_i
            when :'parent-node'
              process_parent_node_tag tag, node
            when :'doc-node'
              ( @child_h[ nil ] ||= [] ).push node.identifier.body_s
            end
          end
        end ; nil
      end

      def process_parent_node_tag tag, node
        child_id_s = node.identifier.body_s
        @parent_h.key? child_id_s and when_multi_parent( node )
        value_s = tag.value
        if value_s
          id_o = normalize_identifier_string value_s
          if id_o
            parent_id_s = id_o.body_s
            @parent_h[ child_id_s ] = parent_id_s
            ( @child_h[ parent_id_s ] ||= [] ).push child_id_s
          end
        end ; nil
      end

      def normalize_identifier_string s
        Snag_::Models::Identifier.normalize s, @delegate
      end

      def when_multi_parent node
        send_info_string "#{ node.identifier.render } has multiple parents - #{
          }using last one." ; nil
      end

      def when_zero
        send_info_string "no nodes in the collection have any parents#{
          } or are doc nodes." ; nil
      end

      def stream_when_nonzero_doc_nodes
        h = determine_every_node_that_is_a_doc_node_recursively
        if h.length.zero?
          stream_when_zero_doc_nodes
        else
          @is_doc_node_h = h
          stream_when_graph
        end
      end

      def determine_every_node_that_is_a_doc_node_recursively
        seen_h = {} ; is_h = {}
        visit_branch_node_p = -> s_a do
          s_a.each do |s|
            seen_h[ s ] and next
            seen_h[ s ] = true
            is_h[ s ] = true
            child_s_a = @child_h[ s ]
            if child_s_a
              visit_branch_node_p[ child_s_a ]
            end
          end
        end
        visit_branch_node_p[ @child_h[ nil ] || EMPTY_A_ ]
        is_h
      end

      def stream_when_zero_doc_nodes
        send_info_string "no nodes in the collection are doc nodes."
        Callback_::Scn.the_empty_stream
      end

      def stream_when_graph
        @node_scn = bld_node_stream
        @advancer_p = method :advance
        @p = @advancer_p
        Callback_::Scn.new do
          @p[]
        end
      end

      def bld_node_stream
        d = -1 ; last = @node_a.length - 1
        Callback_::Scn.new do
          if d < last
            @node_a.fetch d += 1
          end
        end
      end

      def advance
        x = nil
        begin
          @node = @node_scn.gets
          @node or break
          @parent_s = @node.identifier.body_s
          if @is_doc_node_h[ @parent_s ]
            x = when_doc_node
            break
          end
        end while true
        x
      end

      def when_doc_node
        _x = Draw_Node__.new @node
        @s_a = @child_h[ @parent_s ]
        @p = if @s_a
          build_driller
        else
           @advancer_p
        end
        _x
      end

      def build_driller
        scn = bld_doc_child_node_stream
        -> do
          x = scn.gets
          if ! x
            @p = @advancer_p
            x = @p[]
          end
          x
        end
      end

      def bld_doc_child_node_stream
        scn = bld_child_node_stream
        Callback_::Scn.new do
          begin
            s = scn.gets
            s or break
            if @is_doc_node_h[ s ]
              ev = Draw_Arc__.new s, @parent_s
              break
            end
          end while true
          ev
        end
      end

      def bld_child_node_stream
        d = -1 ; last = @s_a.length - 1
        Callback_::Scn.new do
          if d < last
            @s_a.fetch d += 1
          end
        end
      end

      Draw_Node__ = Snag_::Model_::Event.new :node do
        def terminal_channel_i
          :draw_node
        end
      end

      Draw_Arc__ = Snag_::Model_::Event.new :child_s, :parent_s do
        def terminal_channel_i
          :draw_arc
        end
        message_proc do |y, o|
          y << "#{ o.child_s } -> #{ o.parent_s }"
        end
      end
    end
  end
end
