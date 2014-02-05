module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Server

      class Shut_Down__

        # this tributary agent implements the inner mechanics of a "clean-
        # shutdown" with a wide, flat tree of line-oriented callback channels
        # (i.e. many callback) to hook into for whoever the client is.

        Callback_Tree_::Host[ self ]
        Mock_System::Socket_Agent_[ self ]

        callbacks = build_mutable_callback_tree_specification
        callbacks.default_pattern :callback

        def initialize host, message
          super()
          yield @callbacks.build_mutable_conduit
          @context, @socket = host.context_and_socket
          @y = @callbacks.build_yielder_for :info_line
          @host = host ; @message = message
        end
        callbacks << :info_line

        def attempt_to_shutdown
          did = @host.lifepoint_synchronize do |cnt|
            if SERVER_IS_RUNNING_LIFEPOINT_INDEX_ == cnt.lifepoint_index
              cnt.increment_lifepoint_index
              true
            end
          end
          did ? shtdwn_body : when_did_not
        end

      private

        def when_did_not
          @callbacks.call_callback :when_did_not,
            "shutdown already in progress at shudown request #{ @message }"
        end
        callbacks << :when_did_not

        def shtdwn_body
          rc = @callbacks.call_listeners :when_did do
            "shutting down #{ @message } per request"
          end
          @y << "shutting down plugins:"
          d = shutdown_every_plugin
          d and ! rc and rc = d  # any user e.c trumps any plugin e.c
          @callbacks.call_callback :info_line_head,
            "shutting down server #{ @message } .."
          d = close_socket_and_terminate_context
          if d  # any user e.c then any plugin e.c trump any socket e.c
            ! rc and rc = d
          else
            @callbacks.call_callback :info_line_tail, " done."
          end
          rc
        end
        callbacks.listeners :when_did
        callbacks << :info_line_head << :info_line_tail

        def shutdown_every_plugin
          a = @host.call_every_plugin_shorter :on_shutdown
          a and when_some_plugins_have_issues_shutting_down a
        end

        def when_some_plugins_have_issues_shutting_down a
          first_error_code = nil ; is_first = true
          a.each do |i, ec|
            conduit = @host.dereference_plugin_symbol_to_conduit i
            @y << "had issue shutting down '#{ conduit.name.as_human }'#{
              } plugin (exitcode #{ ec })"
            is_first or next
            is_first = false
            first_error_code = ec
          end
          first_error_code
        end

        callbacks.end
      end
    end
  end
end
