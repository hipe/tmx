module Skylab::Snag
  class API::Actions::Node::Number::List < API::Action

    emits :all, error: :all, info: :all, payload: :all

    def execute
      res = nil
      begin
        break if ! issues
        all = issues.manifest.build_enum(nil, nil, nil).with_count!
        valid = all.valid.with_count!
        valid.each do |issue|
          emit(:payload, issue.identifier)
        end
        info "found #{valid.last_count} valid of #{all.last_count} total issues."
        res = true
      end while nil
      res
    end
  end
end
