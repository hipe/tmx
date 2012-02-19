module Skylab::Issue
  class Api::Issue::Add < Api::Action

    attribute :dry_run
    alias_method :dry_run?, :dry_run # @todo
    attribute :issues_file_name, required: true
    attribute :message,          :required => true

    emits :all, :error => :all, :info => :all, :payload => :all

    event_class Api::MyEvent

    def execute
      params! or return
      issues.add(message, :dry_run => dry_run?)
    end
  end
end

