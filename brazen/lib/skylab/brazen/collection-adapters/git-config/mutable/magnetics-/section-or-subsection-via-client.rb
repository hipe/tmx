module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Magnetics_::Section_or_Subsection_via_Client < Common_::MagneticBySimpleModel

        def initialize
          @_execute = :__execute_in_peek_mode
          yield self
        end

        def will_parse_expecting_a_section_line_not_an_assignment_line__
          @_execute = :__execute_not_in_peek_mode ; nil
        end

        attr_writer(
          :client,
        )

        def execute
          send @_execute
        end

        # ("peeking" explained at [#008.E])

        # ~ not peek mode

        def __execute_not_in_peek_mode
          _prepare
          _ok = __parse_whole_line
          _ok && _finish_parse
        end

        # ~ peek mode

        def __execute_in_peek_mode
          _prepare
          self
        end

        def parse_the_beginning_of_the_line__
          _parse_open_brace_passively  # hi.
        end

        def parse_the_rest_of_the_line__
          _ok = _parse_the_rest_of_the_line
          _ok && _finish_parse
        end

        # ~

        def _finish_parse

          This_::Models_::MutableSectionOrSubsection.define do |o|

            o.init_for_parse_based_definition__

            w = @_width_of_subsection_leader
            if w
              o.width_of_subsection_leader = w
              o.width_of_subsection_name = @_width_of_subsection_name
            end

            o.frozen_line = remove_instance_variable( :@_scn_ ).string.freeze

            o.offset_of_name_start = @_offset_of_name_start
            o.width_of_section_name = @_width_of_section_name
          end
        end

        def __parse_whole_line
          ok = __parse_open_brace
          ok &&= _parse_the_rest_of_the_line
        end

        def _parse_the_rest_of_the_line
          ok = __parse_name
          ok &&= __maybe_parse_subsection_name
          ok && __parse_close_brace
        end

        def __parse_close_brace
          skip_ RX_SPACE_
          skip_else_ RX_CLOSE_SQUARE_BRACKET___ do
            whine_ :expected_close_square_bracket
          end
        end

        def __maybe_parse_subsection_name
          if skip_ :@_width_of_subsection_leader, RX_OPEN_QUOTE___
            if skip_ :@_width_of_subsection_name, RX_QUOTED_REST___
              @_width_of_subsection_name -= 1  # pay back the close quote we don't want per #here2
              ACHIEVED_
            else
              whine_ :expected_subsection_name
            end
          else
            ACHIEVED_
          end
        end

        def __parse_name
          @_offset_of_name_start = @_column_offset_
          skip_else_ :@_width_of_section_name, RX_SECTION_NAME_ do
            whine_ :expected_section_name
          end
        end

        def __parse_open_brace
          if _parse_open_brace_passively
            ACHIEVED_
          else
            whine_ :expected_open_square_bracket
          end
        end

        def _parse_open_brace_passively
          skip_ :@_width_of_open_brace, RX_OPEN_BRACE___
        end

        include TheSkipAndWhineMethods_

        def _prepare
          @_scn_ = @client.string_scanner_for_current_line_
          @_column_offset_ = 0
          @_width_of_subsection_leader = nil
        end

        RX_CLOSE_SQUARE_BRACKET___ = /[ ]*\][ ]*(?:[;#]|\r?\n?\z)/
        RX_OPEN_BRACE___ = /[ ]*\[[ ]*/
        RX_OPEN_QUOTE___ = /[ ]+"/
        RX_QUOTED_REST___ = /(?:\\"|\\\\|[^"\n])+"/  # :#here2 we'll have to pay back the accepting of the final quote

        # --
      end

      # ==
      # ==

    end
  end
end
# #history-A: broke out of central "mutable" node (spiritually) during heavy refactor
