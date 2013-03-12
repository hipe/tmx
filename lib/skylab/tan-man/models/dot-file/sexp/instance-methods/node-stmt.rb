module Skylab::TanMan

  module Models::DotFile::Sexp::InstanceMethods::NodeStmt

    include Models::DotFile::Sexp::InstanceMethod::InstanceMethods

    def _create_node_with_label label, error
      # imagine you are the proto
      res = nil
      begin
        node_stmt = __dupe
        ok = node_stmt._set_label_of_prototype! label, error
        ok or break( res = ok )
        res = node_stmt
      end while nil
      res
    end

    def label
      _label_sexp[:content][:equals][:id].normalized_string
    end

    def _label_sexp
      self[:attr_list][:content]._nodes.detect do |n|
        n[:content][:id][:content_text_value] == 'label'
      end
    end


    def _set_label_of_prototype! label_string, error
      res = nil
      begin
        equals = _label_sexp[:content][:equals]
        str = equals[:id].normalized_string

        if TanMan::Template.parameter? str, :label
          s = equals[:id]._escape_string label_string, error
          s or break( res = s )

          out_s = TanMan::Template.from_string( str )[ label: s ]

          # NOTE you lose information above -- you cannot now go back and re-
          # evaluate the template. What you could do is 1) either hold on to
          # the created template object, associate it with this sexp and weirdly
          # re-use it in future regenerations of the node (ick) or manipulate
          # the html with ICK NO THAT'S TERRIBLE

          equals[:id].normalized_string! out_s # oh snap
          res = equals[:id]
        else
          res = _parse_id label_string
          equals[:id] = res
        end
      end while nil
      res
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
