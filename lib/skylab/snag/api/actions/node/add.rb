module Skylab::Snag
  class API::Actions::Node::Add < API::Action

    attribute :dry_run
    attribute :message,          :required => true
    attribute :verbose

    emits :all, :error => :all, :info => :all, :payload => :all

  protected

    def execute
      nodes.add message: message, dry_run: dry_run, verbose: verbose
    end
  end
end
