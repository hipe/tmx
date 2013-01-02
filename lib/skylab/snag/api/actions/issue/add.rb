module Skylab::Issue
  class API::Actions::Issue::Add < API::Action

    attribute :dry_run
    attribute :message,          :required => true
    attribute :verbose

    emits :all, :error => :all, :info => :all, :payload => :all

  protected

    def execute
      issues.add message: message, dry_run: dry_run, verbose: verbose
    end
  end
end
