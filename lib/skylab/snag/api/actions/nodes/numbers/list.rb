module Skylab::Snag

  class API::Actions::Nodes::Numbers::List < API::Action

    # (no attributes.)

    listeners_digraph  info: :lingual,
              output_line: :datapoint

    def execute
      if nodes
        all = nodes.manifest.curry_enum.with_count!
        valid = all.valid.with_count!
        valid.each do |node|
          call_digraph_listeners :output_line, node.rendered_identifier
        end
        info "found #{valid.seen_count} valid of #{all.seen_count} total nodes."
        true
      end
    end
  end
end
