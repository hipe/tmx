module Skylab::Cull

  class Models_::Survey

    class Actions::Mutator

      Actions = ::Module.new

      class Actions::Add < Action_

        Brazen_.model.entity self,

          :required, :property, :path,

          :required, :property, :function_call_expression

        def produce_any_result

          via_path_argument_resolve_existent_survey and
            via_survey
        end

        include Survey_Action_Methods_

      private

        def via_survey

          @exp_s = @argument_box[ :function_call_expression ]

          ok = via_expression_string_resolve_function_call_S_expression
          ok &&= via_function_call_S_expression_resolve_function
          ok && via_function
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

          i_a = Mutator_::Items__.constants

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

        def when_one const
          @function_class = Mutator_::Items__.const_get( const, false )
          ACHIEVED_
        end

        def via_function
          @survey.edit do | o |
            o.add_mutator_to_report(
              @function_class,
              @sexp.arg_s_a,
              nil )
          end
        end
      end

      Mutator_ = Models_::Mutator
    end
  end
end
