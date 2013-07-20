module Skylab::Snag

  # (below line kept for #posterity, it is the twinkle in the eye of the
  # [#sl-123] convention)
  # Todo = Api::Todo # yeah, this sad problem. or is it a pattern!?

  class API::Actions::ToDo::Report < API::Action

    attribute  :be_verbose
    attribute      :names, required: true,
                            default: [ "*#{ Autoloader::EXTNAME }" ] # '*.rb'
    attribute      :paths, required: true
    attribute    :pattern, required: true,
                             default: Snag::Models::Pattern.default
    attribute :show_command_only

    emits            info: :lingual,
                     todo: :datapoint,
                  command: :datapoint,  # only for `show_command_only`
             number_found: :datapoint

  private

    def execute
      ea = Snag::Models::ToDo::Enumerator.new @paths, @names, @pattern
      if @show_command_only
        ea.command.command -> cmd_str do
          emit :command, cmd_str
          true
        end, -> err do
          error err
        end
      else
        ea.on_error method( :error )  # e.g unexpected output from `find`
        ea.on_command do |cmd|  # if strict event handling, we must.
          if @be_verbose
            emit :command, cmd
          end
        end
        res = ea.each do |todo|
          emit :todo, todo
        end
        if ea.seen_count
          emit :number_found, ea.seen_count
        end
        res
      end
    end
  end
end
