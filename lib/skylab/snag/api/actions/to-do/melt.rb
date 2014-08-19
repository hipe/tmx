module Skylab::Snag

  class API::Actions::ToDo::Melt < API::Action

    attribute :be_verbose
    attribute    :dry_run, default: false
    attribute      :names, default: [ "*#{ Autoloader_::EXTNAME }" ] # '*.rb'
    attribute      :paths, required: true, default: ['.']  # not really..
    attribute    :pattern, default: Snag_::Models::Pattern.default
    attribute :working_dir, required: true

    listeners_digraph :error_event,
      :error_string,
      :info_event,
      :info_line,
      :info_string

    inflection.inflect.noun :plural
    inflection.lexemes.noun.plural = "todo's"

  private

    def execute
      _melt = Snag_::Models::Melt.build_controller(
        @dry_run, @be_verbose, @paths, @pattern, @names, @working_dir,
          to_listener, @API_client )
      _melt.melt
    end

    make_sender_methods
  end
end
