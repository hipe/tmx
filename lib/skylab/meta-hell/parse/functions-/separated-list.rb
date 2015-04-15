module Skylab::MetaHell

  module Parse

    class Functions_::Separated_List  # the compliment to "oxford comma" BUT

      # this nonterminal considers a list to be two items or more. this
      # is necessary for operations that place semantic value on the
      # separator used (most of them), for example to discern between
      # an -OR- list and an -AND- list.

      Callback_::Actor.methodic self

      def initialize & edit_p

        instance_exec( & edit_p )

        @p = if @single_separator_mode
          __build_proc_for_one_separator
        else
          __build_proc_for_two_separators
        end
      end

    private

      def item=
        _resolve :@item
      end

      def separator=
        @single_separator_mode = true
        _resolve :@separator
      end

      def non_ultimate_separator=
        @single_separator_mode = false
        _resolve :@non_ultimate_separator
      end

      def ultimate_separator=
        @single_separator_mode = false
        _resolve :@ultimate_separator
      end

      def _resolve ivar

        _sym = @__methodic_actor_iambic_stream__.gets_one

        _cls = Parse_.function_( _sym )

        o = _cls.new_via_iambic_stream_passively @__methodic_actor_iambic_stream__

        o and begin
          instance_variable_set ivar, o
          KEEP_PARSING_
        end
      end

      def __build_proc_for_one_separator

        -> in_st do

          a = nil
          d = in_st.current_index
          d_ = nil

          begin

            x = @item.output_node_via_input_stream in_st
            if ! x
              if d_
                in_st.current_index = d_
              end
              break
            end
            a ||= []
            a.push x

            d_ = in_st.current_index  # memo the point before the sep
            _sep = @separator.output_node_via_input_stream in_st
            if _sep
              redo
            end
            break
          end while nil

          if a && 1 < a.length
            Parse_::Output_Node_.new a
          else
            in_st.current_index = d
            NIL_
          end
        end
      end

      def __build_proc_for_two_separators

        -> in_st do

          a = nil
          d = in_st.current_index

          begin

            x = @item.output_node_via_input_stream in_st
            if ! x
              a = nil
              break  # item is mandatory here
            end

            a ||= []
            a.push x

            _sep = @non_ultimate_separator.output_node_via_input_stream in_st
            if _sep
              redo  # item is mandatory after intermediate separatator
            end

            break  # the only grammatical way out of the loop
          end while nil

          if a  # now the grammar mandates exactly one ult. and one item

            _sep = @ultimate_separator.output_node_via_input_stream in_st
            x = if _sep
              @item.output_node_via_input_stream in_st
            end

            if x
              a.push x
            else
              a = nil
            end
          end

          if a
            Parse_::Output_Node_.new a
          else
            in_st.current_index = d
            NIL_
          end
        end
      end

    public

      def output_node_via_input_stream in_st
        @p[ in_st ]
      end

      NIL_ = nil
    end
  end
end
