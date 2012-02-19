module Skylab::Issue
  class Api::Issue::Number::List < Api::Action

    attribute :issues_file_name, required: true

    emits :all, error: :all, info: :all, payload: :all

    event_class Api::MyEvent

    def execute
      params! or return
      issues.with_manifest do |manifest|
        all = manifest.build_issues_flyweight.with_count!
        valid = all.valid.with_count!
        valid.each do |issue|
          emit(:payload, issue.identifier)
        end
        info "found #{valid.last_count} valid of #{all.last_count} total issues."
      end
      true
    end
  end
end

