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
                             default: Snag_::Models::ToDo.default_pattern_s
    attribute :show_command_only

    listeners_digraph :command_string,
      :error_event,
      :number_found,
      :todo

  private

    def execute
      if @show_command_only
        exec_show_command_only
      else
        exec_normal
      end
    end

    def exec_normal
      scan = Snag_::Models::Todo.build_scan @paths, @pattern, @names,
        :on_command_string, -> cmd_s do
          if @be_verbose
            send_command_string cmd_s
          end
        end,
        :on_error_event, method( :send_error_event )
      scan.each do |todo|
        send_todo todo
      end
      if scan.seen_count
        send_number_found scan.seen_count
      end
      scan.result
    end

    def exec_show_command_only
      Snag_::Models::ToDo.build_scan( @paths, @pattern, @names ).
          command.command -> cmd_str do
        send_command_string cmd_str
        ACHIEVED_
      end, method( :send_error_event )
    end

    make_sender_methods
  end
end
