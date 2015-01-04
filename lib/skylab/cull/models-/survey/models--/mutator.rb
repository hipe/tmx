module Skylab::Cull

  class Models_::Survey

    class Models__::Mutator

      def initialize survey, & oes_p
        @survey = survey
        @on_event_selectively = oes_p
      end

      def add arg, _box
        ok = true
        arg.value_x.each do | s |
          ok, args = Function_class_and_args_via_call_expression[ s, & @on_event_selectively ]
          ok or break
          _add ok, args
        end
        ok
      end

      def _add function_class, any_arg_s_a

        @survey.touch_associated_entity_( :report ).add_function_call(
          any_arg_s_a, function_class, :mutator )

      end

      class Function_class_and_args_via_call_expression

        Callback_::Actor.call self, :properties,

          :exp_s

        def execute
          ok = via_expression_string_resolve_function_call_S_expression
          ok &&= via_function_call_S_expression_resolve_function
          ok and [ @function_class, @sexp.arg_s_a ]
        end

        def via_expression_string_resolve_function_call_S_expression
          md = RX___.match @exp_s
          if md
            s = md[ :args ]
            if s and s.length.nonzero?
              s_a = s.split COMMA_RX_
            end
            @sexp = Call_Sexp__.new md[ :name ], s_a
            ACHIEVED_
          else
            self._DO_ME_invalid_function_call_expression
          end
        end

        RX___ = /\A
          (?<name>  [^\(]+  )
          (?:
            \( [ \t]*  (?<args> | [^\)]* [^ \t] ) [ \t]* \)
          )?
        \z/x

        COMMA_RX_ = /[ \t]*,[ \t]*/

        Call_Sexp__ = ::Struct.new :name_string, :arg_s_a

        def via_function_call_S_expression_resolve_function

          nm = Callback_::Name.via_slug @sexp.name_string

          rx = /\A#{ nm.as_const.id2name.downcase  }/i

          i_a = Models_::Mutator::Items__.constants

          found_a = i_a.reduce [] do | m, const |
            if rx =~ const
              m.push const
            end
            m
          end

          case 1 <=> found_a.length
          when  1 ; when_none nm, i_a
          when  0 ; when_one found_a.first
          when -1 ; self._DO_ME_when_ambiguous found_a, i_a
          end
        end

        def when_none nm, i_a
          maybe_send_event :error, :uninitialized_constant do
            build_not_OK_event_with :uninitialized_constant, :constant, nm.as_const
          end
          UNABLE_
        end

        include Simple_Selective_Sender_Methods_

        def when_one const
          x = Models_::Mutator::Items__.const_get const, false
          @function_class = if x.respond_to? :name
            x
          else
            Proc_Wrapper___.new x, const
          end
          ACHIEVED_
        end
      end

      class Proc_Wrapper___

        def initialize * a
          @p, @const = a
        end

        def name
          @const.id2name
        end

        def [] * a, & p
          @p[ * a , & p ]
        end
      end
    end
  end
end
