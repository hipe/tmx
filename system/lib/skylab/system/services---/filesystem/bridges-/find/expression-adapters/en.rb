module Skylab::System

  class Services___::Filesystem

    class Bridges_::Find

      module Expression_Adapters::EN

        class << self

          def [] cmd

            _x = __filename_phrase cmd
            _x_ = __path_phrase cmd
            _PS::Mutable_phrase_list_as_noun_inflectee.via_phrases _x, _x_
          end

          def __filename_phrase cmd

            _head = _PS::Noun_inflectee_via_string[ 'whose name matched' ]

            tail = _EN.portable_list_phrase.new_via_array cmd.filename_array

            tail.inflect_words_into_against_noun_phrase_under =
            -> y, np, expag, listp do

              listp = listp.dup
              listp.final_separator = 'or'
              listp.item_map = expag.method :val

              listp.inflect_words_into_against_noun_phrase y, np
            end

            _PS::Mutable_phrase_list_as_noun_inflectee.via_phrases(
              _head, tail  )
          end

          def __path_phrase cmd

            tail = _EN.portable_list_phrase.new_via_array cmd.path_array

            tail.inflect_words_into_against_noun_phrase_under =
            -> y, np, expag, listp do

              listp = listp.dup
              listp.final_separator = 'and'
              listp.item_map = expag.method :pth

              listp.inflect_words_into_against_noun_phrase y, np
            end

            _EN::POS::Preposition.phrase_via tail, 'in'
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
  end
end
