module Skylab::System
  # -
    class Services___::Find

      module Expression_Adapters::EN

        class << self

          def [] cmd

            _x = __filename_phrase cmd
            _x_ = __path_phrase cmd
            _PS::Mutable_phrase_list_as_noun_inflectee.via_phrases _x, _x_
          end

          def __filename_phrase cmd

            _head = _PS::Noun_inflectee_via_string[ 'whose name matched' ]

            o = _EN::Sexp.expression_session_for :list, cmd.filename_array

            o.expression_agent_method_for_saying_item :val

            o.be_alternation

            _PS::Mutable_phrase_list_as_noun_inflectee.via_phrases(
              _head, o )
          end

          def __path_phrase cmd

            o = _EN::Sexp.expression_session_for :list, cmd.path_array

            o.expression_agent_method_for_saying_item :pth

            _EN::POS::Preposition.phrase_via o, 'in'
          end

          def _PS
            _EN::Phrase_Structure
          end

          def _EN
            Home_.lib_.human::NLP::EN
          end
        end  # >>
      end
    end
  # -
end
