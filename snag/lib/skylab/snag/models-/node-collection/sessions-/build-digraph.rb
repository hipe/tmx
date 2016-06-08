module Skylab::Snag

  class Models_::Node_Collection

    Sessions_ = ::Module.new

    class Sessions_::Build_Digraph

      def initialize & x_p
        if x_p
          @_oes_p = x_p
        end
      end

      attr_writer :node_upstream

      def execute

        ok = __resolve_stream_of_every_node_tagged_doc_node_or_parent_node

        ok &&= __resolve_hashes_associating_every_parent_node_to_every_child

        ok && __via_hashes
      end

      def __via_hashes

        if @_parent_h.length.zero?
          _when_zero_doc_nodes

        else

          __via_nonzero_doc_nodes_stream
        end
      end

      def __resolve_stream_of_every_node_tagged_doc_node_or_parent_node

        @_total_count = 0

        @_reduced_node_st = @node_upstream.reduce_by do | node |

          @_total_count += 1

          _a = node.is_tagged_with :"doc-node"
          _a or _b = node.is_tagged_with( :"parent-node" )

          _a || _b
        end

        ACHIEVED_
      end

      def __resolve_hashes_associating_every_parent_node_to_every_child

        @_child_h = {}
        @_parent_h = {}

        __prepare_to_iterate

        @_reduced_node_st.each do | node |

          node.to_tag_stream.each do | tag |

            case tag.intern
            when :'parent-node'
              __process_parent_node_tag tag, node

            when :'doc-node'
              ( @_child_h[ nil ] ||= [] ).push node.ID.to_i  # etc
            end
          end
        end

        ACHIEVED_
      end

      def __prepare_to_iterate  # take this and the other and abstract it one day ..

        nid = Home_::Models_::Node_Identifier.new_empty
        @_nid_fly = nid

        @__scan_for_nid = -> str do

          strscn = Home_::Library_::StringScanner.new str

          p = Home_::Models_::Node_Identifier::Expression_Adapters::Byte_Stream.
            build_reinterpreter strscn

          @__scan_for_nid = -> str_ do
            strscn.string = str_
            p[ nid ]
          end
          p[ nid ]
        end
      end

      def __process_parent_node_tag tag, node

        child_id_d = node.ID.to_i

        if @_parent_h.key? child_id_d
          __express_notice_about__multi_parent node
        end

        if tag.value_is_known

          _str = tag.get_value_string

          _x = @__scan_for_nid[ _str ]

          if _x

            parent_id_d = @_nid_fly.to_i

            @_parent_h[ child_id_d ] = parent_id_d
            ( @_child_h[ parent_id_d ] ||= [] ).push child_id_d
          end
        end

        NIL_
      end

      def __express_notice_about__multi_parent node

        self._WAS

        _send_info_string "#{ node.identifier.render } has multiple parents - #{
          }using last one."

        NIL_
      end

      def __via_nonzero_doc_nodes_stream

        h = __build_a_truth_hash_of_every_node_that_is_a_focus_node_indirectly

        if h.length.zero?
          _when_zero_doc_nodes

        else
          @_is_doc_node_h = h
          __rewind_and_produce_node_stream_via_the_is_doc_node_hash
        end
      end

      def __build_a_truth_hash_of_every_node_that_is_a_focus_node_indirectly

        is_h = {}
        seen_h = {}

        visit_branch_node_p = -> d_a do

          d_a.each do | d |

            seen_h[ d ] and next
            seen_h[ d ] = true
            is_h[ d ] = true
            child_d_a = @_child_h[ d ]

            if child_d_a
              visit_branch_node_p[ child_d_a ]
            end
          end
        end

        visit_branch_node_p[ @_child_h[ nil ] || EMPTY_A_ ]

        is_h
      end

      def _when_zero_doc_nodes

        _send_info_string "none of the #{ @_total_count }#{
          } nodes in the collection are doc nodes."

        Common_::Scn.the_empty_stream
      end

      def _send_info_string  s
        @_oes_p.call :info, :expression do | y |
          y << s
        end
        NIL_
      end

      def __rewind_and_produce_node_stream_via_the_is_doc_node_hash

        @node_upstream.upstream.rewind or fail

        @_p = @_advance  = method :__advance

        Common_.stream do
          @_p[]
        end
      end

      def __advance

        x = nil

        begin

          @_node = @node_upstream.gets
          @_node or break

          if @_is_doc_node_h[ @_node.ID.to_i ]
            x = __via_doc_node
            break
          end
          redo
        end while nil

        x
      end

      def __via_doc_node

        _op = Draw_Node___.new @_node

        @_d_a = @_child_h[ @_node.ID.to_i ]

        @_p = if @_d_a
          __build_driller_proc
        else
          @_advance
        end

        _op
      end

      def __build_driller_proc

        st = __build_doc_child_node_stream

        -> do
          x = st.gets
          if ! x
            @_p = @_advance
            x = @_p[]
          end
          x
        end
      end

      def __build_doc_child_node_stream

        st = Common_::Stream.via_nonsparse_array @_d_a

        Common_.stream do
          begin
            d = st.gets
            d or break
            if @_is_doc_node_h[ d ]
              op = Draw_Arc___.new d, @_node.ID.to_i
              break
            end
          end while true
          op
        end
      end

      class Draw_Node___ # < [ operation ]

        def initialize x
          @node = x
        end

        attr_reader :node

        def name_symbol
          :draw_node
        end
      end

      class Draw_Arc___  # < [ operation ]

        def initialize child_d, parent_d
          @child_d = child_d
          @parent_d = parent_d
        end

        attr_reader :child_d, :parent_d

        def name_symbol
          :draw_arc
        end
      end
    end
  end
end
