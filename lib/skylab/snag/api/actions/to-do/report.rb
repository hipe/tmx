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

    listeners_digraph :command_string,
      :error_event,
      :error_string,
      :number_found,
      :todo

  private

    def execute
      @ea = Snag_::Models::ToDo.build_enumerator @paths, @pattern, @names
      if @show_command_only
        exec_show_command_only
      else
        ea = @ea
        ea.on_error_string method :send_error_string
        ea.on_command_string do |cmd_s|  # if strict event handling, we must.
          if @be_verbose
            send_command_string cmd_s
          end
        end
        res = ea.each do |todo|
          send_todo todo
        end
        if ea.seen_count
          send_number_found ea.seen_count
        end
        res
      end
    end

    def exec_show_command_only
      @ea.command.command -> cmd_str do
        send_command_string cmd_str
        ACHIEVED_
      end, method( :send_error_event )
    end

    make_sender_methods
  end
end
