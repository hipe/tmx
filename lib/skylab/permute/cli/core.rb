module Skylab::Permute

  class CLI < Home_.lib_.brazen::CLI

    Actions = ::Module.new
    class Actions::Generate < Action_Adapter

      MUTATE_THESE_PROPERTIES = [ :pair ]

      def mutate__pair__properties

        # exclude this formal property from the front. leave back as-is.

        mutable_front_properties.remove :pair
        NIL_
      end

      # ~ the remainder of this class is the crazy optparse

      undef_method :option_parser_class  # sanity

      def begin_option_parser

        Sessions_::Custom_Option_Parser.new do | * i_a, & ev_p |

          i_a_ = i_a.dup
          if :directive == i_a.first
            i_a_.reverse!
          else
            i_a_.unshift i_a_.pop
          end

          m = :"__receive__#{ i_a_ * UNDERSCORE_ }__"

          send m, ev_p[]
        end
      end

      def __receive__help_directive__ st

        st.advance_one

        if st.unparsed_exists
          arg_s = st.current_token  # downstream this isn't used anyway so meh
        end

        @op.help_pair.last.call arg_s  # probably nil
        NIL_
      end

      def __receive__no_arguments_case__ _

        io = @resources.serr
        io.puts 'please provide one or more name-value pairs'
        hr = help_renderer
        # hr.express_primary_usage_line_
        hr.express_invite_to_general_help
        @_a = false
        maybe_use_exit_status CLI::GENERIC_ERROR
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
          Actors_::Convert_parse_tree_into_iambic_arguments[
            x_a, @_a, & handle_event_selectively ]
        else
          @_a
        end
      end
    end

    Autoloader_[ Actors_ = ::Module.new ]
    EMPTY_A_ = [].freeze
    Autoloader_[ Sessions_ = ::Module.new ]
  end
end
