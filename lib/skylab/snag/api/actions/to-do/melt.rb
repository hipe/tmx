module Skylab::Snag

  class API::Actions::ToDo::Melt < API::Action
    emits :payload, :info, :error

    attribute :dry_run, default: false
    attribute :names, default: ['*.rb']
    attribute :paths, required: true
    attribute :pattern, default: Snag::Models::Pattern.default
    attribute :verbose

    inflection.inflect.noun :plural
    inflection.stems.noun.plural = "todo's"

  protected

    def execute
      res = nil
      begin
        melt = Snag::Models::Melt::Controller.new self,
          paths, dry_run, names, pattern, verbose
        melt.melt
      end while nil
      res
    end
  end
end
