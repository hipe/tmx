module Skylab::TanMan

  module Models_::DotFile::RuleEnhancements::NodeStmt

    include Models_::DotFile::CommonRuleEnhancementsMethods_

    def label_or_node_id_normalized_string
      label || node_id_normalized_string
    end

    def label
      lbl_el = _label_sexp
      if lbl_el
        _id = lbl_el[ :content ][ :equals ][ :id ]
        _id.normal_content_string_
      end
    end

    def _label_sexp
      al = self[ :attr_list ]
      if al
        al[ :content ].elements_.detect do |n|
          n[ :content ][ :id ][ :content_text_value ] == LABEL_LABEL_
        end
      end
    end

    def create_node_with_label__ label, & p
      node_stmt = duplicate_except_
      _ok = Write_label_of_node_made_from_prototype___[ label, node_stmt, & p ]
      _ok && node_stmt
    end

    def node_ID_symbol_

      # #open [#051] nothing for 'port'

      # (this used to #history-A.1 override a member name, which necessitated
      # that our autogenerated classes were a *subclass* of the geneated
      # struct class and not the struct class itself. now we avoid ever
      # overriding grammar names..

      node_id_normalized_string.intern
    end

    def node_id_normalized_string
      self[ :node_id ][ :id ].normal_content_string_
    end

    def set_node_id node_id

      node_id.respond_to? :id2name or raise say_node_id_is_not_symbol node_id
      _element = _parse_id node_id.id2name
      self[ :node_id ][ :id ] = _element
      ACHIEVED_
    end

    def say_node_id_is_not_symbol x
      "sanity - no implicit conversion from #{ x.class } to Symbol for 'node_id'"
    end

    class Write_label_of_node_made_from_prototype___ < Common_::Dyadic

      # result is the new ID element on success, false-ish on failure.
      #
      # this is sub-optimal and confusing intersection of three phenomena,
      # but with some interesting elements and potential:
      #
      # the dot language has some support for some subset of HTML to be used
      # in node labels. (one canonic example uses entire HTML tables for
      # for node labels.)
      #
      # now, *we* support this idea of "protoypes" (example nodes and
      # associations *in comments* that are used as ..er.. prototypes for
      # when creating new nodes).
      #
      # finally, the third crazy thing: we also support this wild ability
      # to put what looks like a template variable ("{{ like_this }}") *in*
      # the label string of the prototype. if such a template variable with
      # the name "label" looks like it is in the existing label string, then
      # when a new label string comes, we extrapolate the new label string
      # *into* the template and use *that* string as the label string. whew!
      #
      # but the paragraph above only applies when inserting a new label into
      # a freshly made node made from a prototype. (that is why there is a
      # dedicated performer (the subject) for this - it has "from prototype"
      # in its name.)
      #
      # now you might see where this is going: if it is the case both that
      # the existing label string is in HTML, *and* we are doing the trick
      # with the templating, then we need to (yikes) escape the unsanitized
      # label string for HTML!
      #
      # as we describe below, doing a comprehensive job for this is outside
      # our scope, but we attempt a proof of concept here and a graceful
      # fail for escaping we don't support.

      def initialize label, node, & p
        @_unsanitized_label_string = label
        @listener = p
        @node = node
      end

      def execute
        __init_ivars
        if __the_existing_label_looks_like_it_has_a_perticular_template_variable_in_it
          __when_template_parameter
        else
          __when_no_template_parameter
        end
      end

      # -- C:

      def __when_template_parameter
        if __escape_the_ID_string
          __call_the_template
        end
      end

      def __call_the_template

        _template_s = remove_instance_variable :@_existing_label
        _tmpl = Home_.lib_.basic::String::Template.via_string _template_s

        _escaped_s = remove_instance_variable :@__escaped_ID_string

        _out_s = _tmpl.call label: _escaped_s

          # NOTE you lose information above -- you cannot now go back and re-
          # evaluate the template. What you could do is 1) either hold on to
          # the created template object, associate it with this sexp and weirdly
          # re-use it in future regenerations of the node (ick) or manipulate
          # the html with ICK NO THAT'S TERRIBLE

        @_the_ID_element.set_normalized_string _out_s
        @_the_ID_element
      end

      def __escape_the_ID_string
        _unsanitized_s = remove_instance_variable :@_unsanitized_label_string
        _ = @_the_ID_element.escape_ID_string__ _unsanitized_s, & @listener
        _store :@__escaped_ID_string, _
      end

      def __the_existing_label_looks_like_it_has_a_perticular_template_variable_in_it

        @_existing_label = @_the_ID_element.normal_content_string_

        Home_.lib_.basic::String::Template.string_has_variable(
          @_existing_label, :label )
      end

      # -- B:

      def __when_no_template_parameter

        _unsanitized_label_string = remove_instance_variable :@_unsanitized_label_string
        el = @node._parse_id _unsanitized_label_string
        remove_instance_variable :@_the_ID_element  # no longer valid
        @_the_equals_element[ :id ] = el
        el
      end

      # -- A:

      def __init_ivars
        @_the_equals_element = @node._label_sexp[ :content ][ :equals ]
        @_the_ID_element = @_the_equals_element[ :id ]
        NIL
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    # ==
    # ==
  end
end
# #history-A.1: begin some cleanup
