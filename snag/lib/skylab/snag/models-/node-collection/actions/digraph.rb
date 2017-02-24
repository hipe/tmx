module Skylab::Snag

  class Models_::NodeCollection

    class Actions::Digraph

      WORDWRAP_ASPECT_RATIO___ = [ 3, 1 ]

      def definition ; [

        :branch_description, -> y do
          y << "write to the output stream a digrpah of doc nodes"
        end,

        :required, :property, :byte_downstream,
        :required, :property, :upstream_reference,

      ] end

      def initialize
        extend ActionRelatedMethods_
        @_invocation_resources_ = yield
        init_action_ @_invocation_resources_
        __init_default_styles
      end

      def execute
        ok = true
        ok &&= __resolve_node_controller
        ok &&= __resolve_node_upstream_via_node_controller
        ok &&= __express_opening
        ok &&= __express_body
        ok &&= __express_closing
        ok || NIL
      end

      def __init_default_styles

        @fillcolor = '#b5d5fb'
        @fontname = 'Helvetica-Narrow'
        @label = '\\N'
        @penwidth = '1.1566'
        @shape = 'Mrecord'
        @style = 'filled'
        NIL_
      end

      NODE_ATTR_I_A__ = [ :fillcolor, :fontname, :label,
        :penwidth, :shape, :style ]

      def __express_opening

        _express_unindented_line 'digraph {'
        __express_label
        __express_prototype_node
      end

      def __express_label

        uid = @upstream_reference
        if uid.respond_to? :to_path

          _express_line "label=\"docs for #{ _esc uid.to_path }\""
        end
        NIL_
      end

      def __express_prototype_node

        _a = NODE_ATTR_I_A__.reduce [] do |m, i|
          x = instance_variable_get :"@#{ i }"
          x or next m
          m.push "#{ i }=\"#{ _esc x }\""
          m
        end

        _express_line "node [#{ _a * ', ' }]"

        ACHIEVED_
      end

      def _esc s
        s = s.dup
        _mutate_string_by_escaping s
        s
      end

      def __express_body

        if __resolve_stream_for_output_body_via_node_upstream
          __express_body_via_stream_for_output_body
        end
      end

      def __express_body_via_stream_for_output_body

        __init_rendering_ivars

        st = remove_instance_variable :@__stream_for_output_body
        begin
          op = st.gets
          op or break
          send :"__#{ op.name_symbol }__", op
          redo
        end while nil

        ACHIEVED_
      end

      def __resolve_stream_for_output_body_via_node_upstream

        _ = Here_::Magnetics_::Digraph_via_NodeUpstream.call(
          remove_instance_variable( :@__node_upstream ),
          & _listener_ )

        _store :@__stream_for_output_body, _
      end

      def __draw_arc__ op

        _express_line "#{ op.child_d }->#{ op.parent_d }"

        NIL_
      end

      def __init_rendering_ivars

        @_expag = Models_::NodeCollection::ExpressionAdapters::ByteStream.
          build_default_expression_agent

        NIL_
      end

      def __draw_node__ op

        node = op.node
        s_a = []
        ww = Home_.lib_.basic::String::WordWrapper::Calm.with(
          :downstream_yielder, s_a,
          :aspect_ratio, WORDWRAP_ASPECT_RATIO___ )


        _id_s = node.ID.express_under @_expag

        st = node.body.to_object_stream_
        begin
          o = st.gets
          o or break

          if :tag == o.category_symbol

            case o.intern
            when PARENT_NODE___
              # nothing
            when DOC_NODE___
              # also nothing
            else
              # what to do with ags you encouner
              ww << o.get_string
            end
          else
            ww << o.get_string.strip
          end
          redo
        end while nil

        ww << _id_s

        ww.flush
        s_a.each do | s |
          _mutate_string_by_escaping s
        end

        _long_label = s_a.join '\n'

        _express_line "#{ node.ID.to_i } [label=\"#{ _long_label }\"]"

        NIL_
      end

      DOC_NODE___ = :'doc-node'
      PARENT_NODE___ = :'parent-node'

      def _mutate_string_by_escaping s

        s.gsub! QUOTE___, BACKSLASH_QUOTE___
        s.gsub! GT___, BACKSLASH_GT___

        NIL_
      end

      BACKSLASH_GT___ = '\\>'
      BACKSLASH_QUOTE___ = '\\"'.freeze
      GT___ = '>'
      QUOTE___ = '"'.freeze

      def __express_closing

        _express_unindented_line '}'
      end

      def _express_line s

        @byte_downstream << "  #{ s }#{ NEWLINE_ }"

        ACHIEVED_
      end

      def _express_unindented_line s

        @byte_downstream << "#{ s }#{ NEWLINE_ }"

        ACHIEVED_
      end

      # --

      # --


      def __resolve_node_upstream_via_node_controller

        _nc = remove_instance_variable :@__node_controller
        _ = _nc.to_entity_stream( & _listener_ )
        _store :@__node_upstream, _
      end

      def __resolve_node_controller

        _ = Here_.via_upstream_reference(
          @upstream_reference, @_invocation_resources_, & _listener_ )

        _store :@__node_controller, _
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # ==
      # ==
    end
  end
end
