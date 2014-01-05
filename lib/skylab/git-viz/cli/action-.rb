module Skylab::GitViz

  class CLI::Action_  # read [#--

    def initialize client
      @client = client
    end

  private

    def invoke_API_with_iambic x_a
      _i = self.class.local_normal_name
      x_a.unshift(  # [#004]: #in-API-invocation-the-order-matters
        :API_action_locator_x, _i,
        :VCS_adapter_name, DEFAULT_VCS_ADAPTER_NAME_I__,
        :VCS_listener, listnr_for_VCS_front,
        :listener, svcs_for_API_action )
      GitViz::API.invoke_with_iambic x_a
    end
    #
    def self.local_normal_name
      Headless::Name::FUN::Local_normal_name_from_module[ self ]
    end

    Headless::Client[ self,
      :client_services,
        :named, :svcs_for_API_action,
        :named, :listnr_for_VCS_front ]

    svcs_for_API_action_class
    class Svcs_For_API_Action
      def call * i_a, & p
        @up_p[].send :"#{ i_a * '_' }_from_API_action", p[] ; nil
      end
    end

    listnr_for_VCS_front_class
    class Listnr_For_VCS_Front
      def call * i_a, & p
        @up_p[].send :"#{ i_a * '_' }_from_VCS", p[]
      end
    end

    def unexpected_stderr_line_from_VCS line
      emit_info_line "#{ _VCS_name } says #{ line }" ; nil
    end

    def cannot_execute_command_string_from_VCS string
      emit_info_line "#{ _VCS_name } says #{ string }"
      say_the_command_leading_up_to_this ; nil
    end

    def unexpected_exitstatus_from_VCS d
      emit_info_line say_nonzero d
      emit_the_command_leading_up_to_this ; nil
    end

    def say_nonzero d
      "had nonzero exitstatus from #{ _VCS_name }: #{ d }. #{
        }will not procede because of this."
    end

    def _VCS_name
      DEFAULT_VCS_ADAPTER_NAME_I__
    end

    def emit_the_command_leading_up_to_this
      emit_info_line say_the_command_leading_up_to_this ; nil
    end

    def next_system_command_from_VCS cmd
      @last_command = cmd ; nil
    end

    def say_the_command_leading_up_to_this
      "(the command leading up to this was: `#{ some_last_command_string }`#{
        }#{ say_any_appended_command_detail })"
    end

    def some_last_command_string
      @last_command.command_s_a * ' '  # #storypoint-75
    end

    def say_any_appended_command_detail
      s = say_any_command_detail
      " #{ s }" if s
    end

    def say_any_command_detail
      if (( h = @last_command.any_nonzero_length_option_h ))
        a = h.reduce [] do |m, (k, v)|
          s = send :"say_any_command_detail_for_#{ k }", v
          s and m << s ; m
        end
        a * ' ' if a.length.nonzero?
      end
    end

    def say_any_command_detail_for_chdir s
      "executed from #{ s }"  # :+#system-path
    end

    def pay_line_from_API_action s
      emit_payload_line s
    end

    def info_line_from_API_action s
      emit_info_line s
    end

    def emit_payload_line s
      @client.emit_on_channel_line :payload, s ; nil
    end

    def emit_info_line s
      @client.emit_on_channel_line :info, s ; nil
    end

    DEFAULT_VCS_ADAPTER_NAME_I__ = :git

  end
end
