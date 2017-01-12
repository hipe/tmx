module Skylab::Basic

  class StateMachine

    class DrivenSession___ < SimpleModel_

      # in contrast to an "active" session where the parsing algorithm
      # "drives" the parse and draws more tokens of input as fast as it
      # can until it reaches the end of input (or a complete parse),

      # and in contrast to a "passive" parse where the user "pulls" pages
      # of parse structure on-demand,

      # in this arrangement the user gets a writable exposures proxy.
      # as the user sees fit, she writes more input tokens into this proxy
      # and then calls close when finished. in real-time, at each step
      # the parser will only consume those tokens that have been given to
      # it to that point.

      # the only way the user can get the pieces of the parse result is
      # through a callback called from the grammar.

      # this is a rough pass, but it seems certain that grammars for a
      # "driven" parse have constraits on them that other grammars don't
      # (see holes)

      # -
        def initialize
          yield self
        end

        attr_writer(
          :downstream_by,
          :page_listener,  # overloaded name
        )

        def define_active_session__ as

          as.upstream = UpstreamProxy___.new(
            -> { send @_current_token },
            -> { send @_advance_token },
          )

          as.downstream_by = remove_instance_variable :@downstream_by

          as.page_listener = self
          NIL
        end

        def active_session= as
          @_ = as ; nil
        end

        def execute  # i.e init
          @_.init_state
          @_page = :__page_initially
          self
        end

        def puts token
          @__current_token = token
          @_current_token = :__CT_yes
          @_advance_token = :__AT_yes

          _ok = @_.step_via_find_transition
          _ok || self._PARSE_FAILED  # we don't have listener so should fail anyway
          if @_.state.has_handler
            __step_via_handler
          else
            ::Kernel._K
          end
          NIL
        end

        def __step_via_handler
          o = @_.invoke_handler_via_user_matchdata
          if o.set_a_directive
            self._NEVER__set_a_directive_in_driven_mode__
          elsif o.had_a_trueish_result
            @_.step_when_trueish_result o.trueish_result
          elsif @_.state.has_at_least_one_formal_transition
            NIL
          else
            ::Kernel._K
          end
        end

        def send_any_previous_and_reinit_downstream
          send @_page
        end

        def __page_initially
          @_page = :__page_normally
          @_.reinit_downstream
          NIL
        end

        def __page_normally
          _release_and_send_current_downstream
          @_.reinit_downstream
          NIL
        end

        def close
          _release_and_send_current_downstream
          @_current_token = :_CLOSED
          @_advance_token = :_CLOSED
          remove_instance_variable :@page_listener
          remove_instance_variable :@_page
          remove_instance_variable :@_
          freeze
          NIL
        end

        def _release_and_send_current_downstream
          _ds = @_.release_downstream
          @page_listener[ _ds ]  # NOTE not the same as ivar of same name in sibling
          NIL
        end

        def __CT_yes
          @__current_token
        end

        def __AT_yes
          remove_instance_variable :@__current_token
          @_current_token = :_LOCKED
          @_advance_token = :_LOCKED
        end
      # -
      # ==
      class UpstreamProxy___

        def initialize p, p_
          @advance_one = p_
          @current_token = p
        end

        def current_token
          @current_token[]
        end

        def advance_one
          @advance_one[]
        end

        def no_unparsed_exists
          false
        end
      end
      # ==
    end
  end
end
# #born:
