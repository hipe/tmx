module Skylab::Snag
  class API::Actions::Nodes::Numbers::List < API::Action

    emits :all, error: :all, info: :all, payload: :all

    def execute
      res = nil
      begin
        break if ! nodes
        all = nodes.manifest.build_enum(nil, nil, nil).with_count!
        valid = all.valid.with_count!
        valid.each do |node|
          emit :payload, node.rendered_identifier
        end
        info "found #{valid.seen_count} valid of #{all.seen_count} total nodes."
        res = true
      end while nil
      res
    end
  end
end
