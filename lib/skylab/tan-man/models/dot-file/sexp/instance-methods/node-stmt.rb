module Skylab::TanMan::Models::DotFile::Sexp::InstanceMethods
  module NodeStmt
    include Common

    def _create_node_with_label label
      # imagine you are the proto
      node_stmt = __dupe
      node_stmt._set_label_of_prototype! label
      node_stmt
    end

    def label
      _label_sexp[:content][:equals][:id].normalized_string
    end

    def _label_sexp
      self[:attr_list][:content]._nodes.detect do |n|
        n[:content][:id][:content_text_value] == 'label'
      end
    end

    def _set_label_of_prototype! label_str
      label_sexp = _label_sexp ; equals = label_sexp[:content][:equals]
      str = equals[:id].normalized_string
      if TanMan::Template.parameter? str, :label
        use_label_string = equals[:id]._escape_string label_str
        out_s = TanMan::Template.from_string(str).call(label: use_label_string)
        # NOTE you lose information above -- you cannot now go back and re-
        # evaluate the template. What you could do is 1) either hold on to
        # the created template object, associate it with this sexp and weirdly
        # re-use it in future regenerations of the node (ick) or manipulate
        # the html with ICK NO THAT'S TERRIBLE
        equals[:id].normalized_string! out_s # oh snap
        equals[:id]
      else
        equals[:id] = _parse_id(label_str)
      end
    end

    def node_id # #override # support for 'port' at [#051]
      self[:node_id][:id].normalized_string.intern
    end

    def node_id! node_id
      ::Symbol === node_id or fail("sanity: Symbol not #{node_id.class} please")
      self[:node_id][:id] = _parse_id node_id.to_s
    end
  end
end
