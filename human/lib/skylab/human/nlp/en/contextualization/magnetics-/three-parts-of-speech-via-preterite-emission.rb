module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Three_Parts_Of_Speech_via_Preterite_Emission

        # primarily, effect the assumption that the emission expression is a
        # a preterite string whose intended subject is the association.
        # simply prefix the preterite string with the association name as-is:
        #
        #     "password" + "cannot .." = "password cannot .."
        #
        # experimentally this is also an amalgamation that folds-in the
        # "classic" style of selection stack expression:
        #
        #     "can't frob because password cannot .."

        def ___receive_emission i_a, & ev_p

          # call the downhandler first before you do any more work because
          # maybe the client doesn't event want the event or expression

          # (this feels like #[#ca-046] emission handling pattern but isn't.)

          if :expression == i_a[ 1 ]
            __receive_expression i_a, & ev_p
          else
            __receive_event i_a, & ev_p
          end
        end

        def __receive_event i_a, & ev_p

          # hacked together for [my] but hrm just a sketch for now:
          # contextualize events by "casting" them to expressions

          wicked = i_a.dup
          wicked[ 1, 0 ] = [ :expression ]

          kns = @knowns_ ; me = self

          kns.emission_downhandler.call( * wicked ) do |y|

            ev = ev_p[]

            kns.channel = i_a
            kns.emission_proc = -> y_ do
              ev.express_into_under y_, self
            end
            me._express_into y
          end
          NIL_
        end

        def __receive_expression i_a, & ev_p

          kns = @knowns_ ; me = self

          kns.emission_downhandler.call( * i_a ) do |y|
            kns.channel = i_a
            kns.emission_proc = ev_p
            me._express_into y
          end

          NIL_
        end

        def _express_into y

          ma = Home_.lib_.basic::Yielder::Mapper.new

          ma.map_first_by( & method( :___map_first_line ) )

          ma.map_subsequent_by( & Plus_newline_if_necessary_ )

          ma.downstream_yielder = y

          @knowns_.expression_agent.calculate ma.y, & @knowns_.emission_proc

          y
        end

        def ___map_first_line line

          o = Magnetics_::Contextualized_Line_via_Line_and_Emission.begin
          o.line = line
          o.parameter_store = @knowns_
          o.to_pre_articulate_ = method :___pre_articulate
          @_line_c15n = o
          o.execute
        end

        def ___pre_articulate

          kns = @knowns_

          if ! kn.magnetic_value_is_known :trilean
            Magnetics_::Trilean_via_Channel.into_via_magnetic_parameter_store kns
          end

          Here_::Express_Selection_Stack___::Classically___[ kns ]
          so = @knowns_.bound_solver_

          # the next 5: "while" "app" "was adding" "fizbuz" (comma), "password"

          ipc = so.solve_for_( :prefixed_cojoinder ).value_x
          vs = kns.verb_subject.value_x
          iv = so.solve_for_( :inflected_verb ).value_x
          vo = kns.verb_object.value_x
          so = Models_::String_via_Subject_Association[ xx ]

          # ==

          as = Home_::Phrase_Assembly.begin_phrase_builder

          as.add_any_string ipc

          as.add_any_string vs

          as.add_string iv

          as.add_any_string vo

          if ipc
            as.add_comma
          else
            as.add_string 'because'
          end

          as.add_string so

          as.add_lazy_space

          _ = as.string_via_finish

          @_line_c15n.mutate_line_parts_by do |mlp|

            mlp.prefix = _

            mlp.close = Plus_newline_if_necessary_[ mlp.close || EMPTY_S_ ]
          end

          # (no suffix)

          NIL_
        end
    end
  end
end
