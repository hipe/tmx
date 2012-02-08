module Skylab::Issue
  class Api::Issue::Add < Api::Action

    attribute :dry_run
    alias_method :dry_run?, :dry_run # @todo
    attribute :issues_file_name, :required => true
    attribute :message,          :required => true

    emits :all, :error => :all, :info => :all, :payload => :all

    muxer_event_class Api::MyEvent

    def execute
      internalize_params! or return false
      issues.add(message, :dry_run => dry_run?)
    end
  end
end

