module Skylab::TanMan::Models::DotFile::Sexp::InstanceMethods
  module NodeStmt
    include Common
    def _create_node_with_label label
      # imagine you are the proto
      other = __dupe
      other._label_sexp[:content][:equals][:id] = _parse_id(label)
      other
    end
    def label
      _label_sexp[:content][:equals][:id].normalized_string
    end
    def _label_sexp
      self[:attr_list][:content]._nodes.detect do |n|
        n[:content][:id][:content_text_value] == 'label'
      end
    end
    def node_id # #override # #todo:port
      self[:node_id][:id].normalized_string.intern
    end
    def node_id! node_id
      ::Symbol === node_id or fail("sanity: Symbol not #{node_id.class} please")
      self[:node_id][:id] = _parse_id node_id.to_s
    end
  end
end
