module Skylab::Snag

  # (below line kept for #posterity, it is the twinkle in the eye of the
  # [#sl-123] convention)
  # Todo = Api::Todo # yeah, this sad problem. or is it a pattern!?

  class API::Actions::ToDo::Report < API::Action

    attribute  :be_verbose
    attribute      :names, required: true,
                            default: [ "*#{ Autoloader_::EXTNAME }" ] # '*.rb'
    attribute      :paths, required: true
    attribute    :pattern, required: true,
                             default: Snag_::Models::Pattern.default
    attribute :show_command_only

    listeners_digraph  info: :lingual,
                     todo: :datapoint,
                  command: :datapoint,  # only for `show_command_only`
             number_found: :datapoint

  private

    def execute
      @ea = Snag_::Models::ToDo.build_enumerator @paths, @pattern, @names
      if @show_command_only
        exec_show_command_only
      else
        ea = @ea
        ea.on_error method :error_event
        ea.on_command do |cmd|  # if strict event handling, we must.
          if @be_verbose
            send_to_listener :command, cmd
          end
        end
        res = ea.each do |todo|
          send_to_listener :todo, todo
        end
        if ea.seen_count
          send_to_listener :number_found, ea.seen_count
        end
        res
      end
    end

    def exec_show_command_only
      @ea.command.command -> cmd_str do
        send_to_listener :command, cmd_str
        ACHIEVED_
      end, method( :error_event )
    end
  end
end
