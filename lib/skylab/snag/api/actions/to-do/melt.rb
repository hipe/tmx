module Skylab::Snag

  class API::Actions::ToDo::Melt < API::Action

    attribute :be_verbose
    attribute    :dry_run, default: false
    attribute      :names, default: [ "*#{ Autoloader_::EXTNAME }" ] # '*.rb'
    attribute      :paths, required: true, default: ['.']  # not really..
    attribute    :pattern, default: Snag_::Models::Pattern.default

    listeners_digraph  info: :lingual,
                 raw_info: :datapoint,
                  payload: :datapoint

    inflection.inflect.noun :plural
    inflection.lexemes.noun.plural = "todo's"

  private

    def execute
      res = nil
      begin
        melt = Snag_::Models::Melt::Controller.new self,
          @paths, @dry_run, @names, @pattern, @be_verbose
        melt.melt
      end while nil
      res
    end
  end
end
