module Skylab::Zerk

  class NonInteractiveCLI

    module Custom_Effection___  # code notes in [#037]

      class Find < Common_::Actor::Dyadic

        def initialize x, cli
          @x = x
          @CLI = cli
        end

        def execute

          __orient
          __determine_from_module_and_maybe_reorient
          _ok = __attempt_to_resolve_value_for_const_array
          if _ok
            __cash_money
          else
            self
          end
        end

        def __attempt_to_resolve_value_for_const_array

          _a = @_would_be_const_a
          _ = @_from_module

          ev = nil

          x = Common_::Autoloader.const_reduce _a, _ do |ev_|
            ev = ev_
            UNABLE_
          end

          if x
            @__found_x = x
            ACHIEVED_
          else
            @_m = :__build_exception_for_uninitialized_const
            @__name_error_event = ev
            UNABLE_
          end
        end

        def __build_exception_for_uninitialized_const

          msg = "either implement `express_into_under` on #{ @x.class.name }#{
            } -OR- put something at "

          @__name_error_event.express_into_under msg, @CLI.expression_agent

          No.new msg, @_would_be_const_a
        end

        No = ::Class.new ::NameError  # don't catch. #"note-1"

        def __cash_money
          Found___.new @__found_x, @CLI
        end

        def __orient

          st = @CLI.top_frame.to_frame_stream_from_bottom

          root_frame = st.gets

          # (we could do this step-by-step or we could do it in batch steps..)
          # (the latter is easier to debug and has little cost over the former)

          would_be_const_a = [ :NonInteractive, :CustomEffecters ]

          curr_frame = st.gets
          begin
            would_be_const_a.push curr_frame.name.as_const
            next_frame = st.gets
            next_frame or break
            curr_frame = next_frame
            redo
          end while nil

          @_ACS_class = root_frame.ACS.class
          @_operation_frame = curr_frame
          @_would_be_const_a = would_be_const_a ; nil
        end

        def __determine_from_module_and_maybe_reorient

          mod = @CLI.location_module
          if mod
            @_from_module = mod
          else
            @_would_be_const_a[ 0, 0 ] = [ :CLI ]
            @_from_module = @_ACS_class  # might only be for testing :/
          end
          NIL_
        end

        # --

        def ok
          false
        end

        def to_exception
          send @_m
        end
      end

      # ==

      class Found___

        def initialize proc_ish, cli
          @__proc_ish = proc_ish
          @CLI = cli
        end

        def effect_for x
          @__proc_ish[ x, @CLI ]
        end

        def ok
          true
        end
      end

      # ==
    end
  end
end
# #pending-rename (look at usage in this lib)
