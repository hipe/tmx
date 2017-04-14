module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Magnetics::TouchComparableElement_via_Element_and_Comparator_and_Elements < Common_::MagneticBySimpleModel

        # #[#011] an implementation of "unobtrusive lexical-esque ordering"

        def initialize
          yield self
        end

        attr_writer(
          :comparator,
          :element,
          :elements,
        )

        def execute

          compare = remove_instance_variable :@comparator

          st = Stream_[ @elements ]
          offset = -1
          interesting_offset = nil
          begin
            el = st.gets
            el || break
            offset += 1

            d = compare[ el ]

            case d
            when -1
              found_above_neigbhor = true
              interesting_offset = offset
              redo
            when 0
              found_exact_match = true
              break
            when 1
              found_below_neighbor = true
              interesting_offset = offset
              break
            else never
            end
          end while above

          # (the below 3 interesting ones are #cov1.1)

          if found_exact_match

            __when_exact_match el, offset

          elsif found_below_neighbor

            __insert_before_below_neighbor interesting_offset

          elsif found_above_neigbhor

            __insert_after_above_neighbor interesting_offset
          else
            __append_element
          end
        end

        def __insert_before_below_neighbor offset

          @elements[ offset, 0 ] = [ @element ]

          StatusAdded_.new offset
        end

        def __insert_after_above_neighbor offset

          @elements[ offset + 1, 0 ] = [ @element ]

          StatusAdded_.new offset
        end

        def __append_element

          offset = @elements.length
          @elements.push @element

          StatusAdded_.new true, offset
        end

        def __when_exact_match el, offset

          StatusFoundExisting___.new el, offset
        end

        # ==

          # @listener.call :info, :found_existing
          # @listener.call :info, :inserting_item

        # ==

        class StatusFoundExisting___
          # (keep API close close to `StatusAdded_`)

          def initialize el, offset
            @existing_element = el
            @offset = offset
          end

          attr_reader(
            :existing_element,
            :offset,
          )

          def did_add
            FALSE
          end

          def found_existing
            TRUE
          end
        end

        # ==
        # ==
      end
    end
  end
end
# #history-A: broke out of central "mutable" node (spiritually) during heavy refactor
