module Skylab::TestSupport

  module DocTest

    module Models_::Front

      Modalities = ::Module.new

      module Modalities::CLI

        Actions = ::Module.new

        class Actions::Permute < DocTest_::CLI::Action_Adapter

          MUTATE_THESE_PROPERTIES = [ :permutations, :stdout, :stderr ]

          def mutate__permutations__properties

            mutable_front_properties.remove :permutations
          end

          def mutate__stdout__properties

            mutable_front_properties.remove :stdout
          end

          def mutate__stderr__properties

            mutable_front_properties.remove :stderr
          end

          def begin_option_parser

            @_lib = TestSupport_.lib_.permute

            o = @_lib::CLI::Sessions_::Custom_Option_Parser.new( & __me )

            o.mutate_syntax_string_parts = -> s_a do
              s_a.concat help_renderer.any_argument_glyphs
            end

            o
          end

          def __me

            -> * i_a, & ev_p do

              i_a_ = i_a.dup
              if :directive == i_a.first
                i_a_.reverse!
              else
                i_a_.unshift i_a_.pop
              end

              send :"__receive__#{ i_a_ * UNDERSCORE_ }__", ev_p[]
            end
          end

          def __receive__help_directive__ st

            st.advance_one
            @op.help_pair.last.call nil
            NIL_
          end

          def __receive__no_arguments_case__ _
            UNABLE_
          end

          def __receive__no_available_state_transition_error_case__ ev

            _ev_ = ev.new_with :error_category, :optionparser_parseerror

            _ex_ = _ev_.to_exception

            raise _ex_  # sadly, it is "best" to follow unpleasant stdlib o.p API
          end

          def __receive__parsed_nodes_payload_array__ a

            @_a = a
            NIL_
          end

          def prepare_backstream_call x_a

            if @_a

              y = []

              ok = @_lib::CLI::Actors_::Convert_parse_tree_into_iambic_arguments[
                y, @_a, & handle_event_selectively ]

              if ok
                @_a = nil
                __the_rest x_a, y
              else
                ok
              end
            else
              @_a
            end
          end

          def __the_rest x_a, y

            y.unshift :generate

            _kr = @_lib.application_kernel_

            bc = _kr.bound_call_via_mutable_iambic y, & handle_event_selectively

            st = bc.receiver.send bc.method_name, * bc.args

            if st
              o = resources
              x_a.push :stdout, o.sout
              x_a.push :stderr, o.serr
              x_a.push :permutations, st
              ACHIEVED_
            else
              st
            end
          end
        end
      end
    end
  end
end
