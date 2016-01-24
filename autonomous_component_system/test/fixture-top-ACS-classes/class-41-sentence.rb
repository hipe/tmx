module Skylab::Autonomous_Component_System::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_41_Sentence

      module Common_Instance_Methods__

        def receive_component__error__
          self._RESPOND_TO_ONLY
        end

        def receive_component__error__expression__ qkn, sym, & ev_p
          _expy qkn, sym, & ev_p
        end

        def component_event_model
          :hot
        end
      end

      # -

        include Common_Instance_Methods__

        def initialize & p
          @_my_oes_p = p
        end

        def __subject__component_association
          Here_::Class_71_File_Name
        end

        def __verb_phrase__component_association
          Verb_Phrase
        end

        def _set_subject x
          @subject = x ; nil
        end

        def _set_verb_phrase o
          @verb_phrase = o ; nil
        end

        def _expy qkn, sym, & ev_p

          @_my_oes_p.call :error, :expression, sym do | y |

            instance_exec y, & ev_p
          end
          NIL_
        end
      # -

      class Verb_Phrase

        include Common_Instance_Methods__

        def self.interpret_compound_component p, & x
          p[ new( & x ) ]
        end

        def initialize & pp
          @_my_pp = pp
        end

        def __verb__component_association
          Here_::Class_71_File_Name
        end

        def __object__component_association
          Here_::Class_71_File_Name
        end

        def _set_verb x
          @verb = x ; nil
        end

        def _set_object x
          @object = x ; nil
        end

        def _expy qkn, sym, & ev_p

          _oes_p = @_my_pp[ self ]

          _oes_p.call :error, :expression, sym do | y |

            instance_exec y, & ev_p
          end
          NIL_
        end
      end
    end
  end
end
