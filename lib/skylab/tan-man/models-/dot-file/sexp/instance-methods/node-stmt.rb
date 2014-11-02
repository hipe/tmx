module Skylab::TanMan

  module Models_::DotFile::Sexp::InstanceMethods::NodeStmt

    include Models_::DotFile::Sexp::InstanceMethod::InstanceMethods

    def label_or_node_id_normalized_string
      label || node_id_normalized_string
    end

    def label
      attr = _label_sexp
      attr and attr[ :content ][ :equals ][ :id ].normalized_string
    end

    def _label_sexp
      al = self[ :attr_list ]
      if al
        al[ :content ]._nodes.detect do |n|
          n[ :content ][ :id ][ :content_text_value ] == LABEL__
        end
      end
    end

    LABEL__ = 'label'.freeze

    def _create_node_with_label label, error
      node_stmt = __dupe
      ok = Set_label_of_new_node_made_from_prototype__[ label, node_stmt, error ]
      ok && node_stmt
    end

    def node_id  # #override # support for 'port' at [#051]
      node_id_normalized_string.intern
    end

    def node_id_normalized_string
      self[ :node_id ][ :id ].normalized_string
    end

    def set_node_id node_id
      node_id.respond_to?( :id2name ) or raise say_node_id_is_not_symbol( node_id )
      self[ :node_id ][ :id ] = _parse_id node_id.id2name
      ACHIEVED_
    end

    def say_node_id_is_not_symbol x
      "sanity - no implicit conversion from #{ x.class } to Symbol for 'node_id'"
    end

    class Set_label_of_new_node_made_from_prototype__

      Callback_::Actor[ self, :properties, :label, :node, :error_ev_p ]

      def execute
        @equals = @node._label_sexp[ :content ][ :equals ]
        @str = @equals[ :id ].normalized_string
        if TanMan_::Lib_::String_lib[].template.string_has_parameter @str, :label
          when_template_parameters
        else
          when_no_template_parameters
        end
      end

      def when_template_parameters
        s = @equals[ :id ]._escape_string @label, @error_ev_p
        s and begin
          _tmpl = TanMan_::Lib_::String_lib[].template.via_string @str
          out_s = _tmpl.call label: s

          # NOTE you lose information above -- you cannot now go back and re-
          # evaluate the template. What you could do is 1) either hold on to
          # the created template object, associate it with this sexp and weirdly
          # re-use it in future regenerations of the node (ick) or manipulate
          # the html with ICK NO THAT'S TERRIBLE

          @equals[ :id ].set_normalized_string out_s
          @equals[ :id ]
        end
      end

      def when_no_template_parameters
        x = @node._parse_id @label
        @equals[ :id ] = x
        x
      end
    end
  end
end
