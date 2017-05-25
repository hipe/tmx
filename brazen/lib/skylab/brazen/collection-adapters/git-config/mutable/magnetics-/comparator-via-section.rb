module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Magnetics_::Comparator_via_Section < Common_::MagneticBySimpleModel

        # (reminder: this is used by our nearby implementation of [#ba-045]
        # (the unobtrusive lexical-esque ordering algorithm) which takes as an
        # argument all collection elements as an array, so check the symbol
        # categorgy of every incoming element when you are comparing.)

        def initialize
          @_execute = :__execute_normally
          yield self
        end

        def THIS_ONE_THING
          @_execute = :__when_name_only
        end

        attr_writer(
          :section,
        )

        def execute

          compare_of_same_category = send @_execute

          target_cat_sym = @section._category_symbol_

          -> el do
            if target_cat_sym == el._category_symbol_
              compare_of_same_category[ el ]
            else
              -1  # imagine a comment. keep searching. we should go after it.
            end
          end
        end

        def __execute_normally

          s = @section.subsection_string
          if s
            __when_both s
          else
            __when_one
          end
        end

        def __when_both subsect_s

          sect_s = @section.internal_normal_name_string

          -> el do
            d = el.internal_normal_name_string <=> sect_s
            if d.zero?
              subsect_s_ = el.subsection_string
              if subsect_s_
                subsect_s_ <=> subsect_s
              else
                -1
              end
            else
              d
            end
          end
        end

        def __when_one

          sect_s = @section.internal_normal_name_string

          -> el do

            d = el.internal_normal_name_string <=> sect_s
            if d.zero?
              _yes = el.subsection_string
              _yes ? 1 : 0
            else
              d
            end
          end
        end

        def __when_name_only

          sect_s = @section.internal_normal_name_string

          -> el do
            el.internal_normal_name_string <=> sect_s
          end
        end

        # ==
        # ==

      end
    end
  end
end
# #history-A: broke out of central "mutable" node (spiritually) during heavy refactor
