module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Magnetics_::Assignment_via_Client < Common_::MagneticBySimpleModel

        # assignment lines fit into our simple parsing algorithm, where they
        # are one of three categories of line: any line that is not a
        # comment-or-blank and not a section will be attempted to be parsed
        # as an assigment line. see [#008.D]

        def self.[] client  # (prettier one-liners)
          call_by do |o|
            o.client = client
          end
        end

        def initialize
          yield self
        end

        attr_writer(
          :client,
        )

        def execute

          __prepare

          skip_else_ :@_offset_of_name_start, RX_SPACE_

          ok = nil

          This_::Models_::MutableAssignment.define do |o|
            o.init_for_parse_based_definition__
            @_parse_tree = o
            ok = __parse_name
            ok && __parse_the_rest
          end

          ok and remove_instance_variable :@_parse_tree
        end

        # -- C

        def __parse_the_rest

          if __parse_equals_passively

            skip_else_ RX_SPACE_  # @_width_of_space_after_equals

            __parse_right_hand_side_of_equals
          else
            __parse_end_of_line
          end
        end

        def __parse_end_of_line
          if _skip_the_rest
            ACHIEVED_
          else
            whine_ :expected_equals_sign_or_end_of_line
          end
        end

        def __parse_equals_passively
          skip_ RX_EQUALS___  # @_width_of_equals
        end

        def __parse_right_hand_side_of_equals

          @_offset_of_value_start = @_column_offset_  # might contain open quote!

          if skip_ :@_width_of_value, RX_RHS_INTEGER___
            _will :__unmarshal_integer_

          elsif skip_ :@_width_of_value, RX_RHS_BOOLEAN_TRUE___
            _will :__unmarshal_TRUE_

          elsif skip_ :@_width_of_value, RX_RHS_BOOLEAN_FALSE___
            _will :__unmarshal_FALSE_

          else
            __challenge_mode_parse_string
          end
        end

        def _will m
          @_parse_tree._will_use_unmarshal_method_ m
          _finish_line
        end

        # -- B

        def __challenge_mode_parse_string

          @_string_segments = []

          o = _parsing_of_NON_quoted_string

          if o.failed_hard
            UNABLE_
          elsif o.succeeded
            __parse_any_strings_after_NON_quoted_string
          else
            o = _parsing_of_QUOTED_string

            if o.failed_hard
              UNABLE_
            elsif o.failed_softly
              whine_ :expected_integer_or_boolean_or_quoted_or_non_quoted_string
            else
              __parse_any_strings_after_QUOTED_string
            end
          end
        end

        # -- B.3

        def _maybe_finish_parsing_string last

          if last.failed_hard
            UNABLE_
          else
            @_width_of_value = @_column_offset_ - @_offset_of_value_start
            _ok = _finish_line
            _ok &&= __finish_when_value_is_string
          end
        end

        def __finish_when_value_is_string

          _s_a = remove_instance_variable :@_string_segments

          @_parse_tree.accept_already_unmarshaled_value_ _s_a.join.freeze

          ACHIEVED_
        end

        # -- B.2

        def __parse_any_strings_after_NON_quoted_string

          begin
            last = _parsing_of_QUOTED_string
            last.succeeded || break
            last = _parsing_of_NON_quoted_string
            last.succeeded || break
            redo
          end while above

          _maybe_finish_parsing_string last
        end


        def __parse_any_strings_after_QUOTED_string

          # (copy-paste-modify)

          begin
            last = _parsing_of_NON_quoted_string
            last.succeeded || break
            last = _parsing_of_QUOTED_string
            last.succeeded || break
            redo
          end while above

          _maybe_finish_parsing_string last
        end

        # -- B.1

        def _parsing_of_NON_quoted_string

          col_d = @_column_offset_

          if skip_ :@__width, RX_NON_QUOTED_STRING___

            _w = remove_instance_variable :@__width

            _ = @_scn_.string[ col_d, _w ]

            # (the above string is both "encoded" and "raw" - we accept
            # it as-is pursuant to our rules about parsing bare strings
            # not enclosed in quotes. #cov1.4)

            @_string_segments.push _
            PARSING_SUCCEEDED__

          else
            PARSING_FAILED_SOFTLY__
          end
        end

        def _parsing_of_QUOTED_string

          if skip_ RX_DOUBLE_QUOTE___
            __enjoy_parsing_this_quoted_string
          else
            PARSING_FAILED_SOFTLY__
          end
        end

        def __enjoy_parsing_this_quoted_string

          @_offset_of_quoted_string_content = @_column_offset_

          if skip_ :@_width_of_quo, RX_THE_REST_OF_THE_DOUBLE_QUOTED_STRING___

            __continue_enjoying_to_parse_this_quoted_string
          else
            whine_ :end_quote_not_found_anywhere_before_end_of_line
            PARSING_FAILED_HARD__
          end
        end

        def __continue_enjoying_to_parse_this_quoted_string

          @_scn_.pos += 1  # totally nasty - rx doesn't include close..
          @_column_offset_ += 1  # ..quote, same reason here. see #here1

          _d = remove_instance_variable :@_offset_of_quoted_string_content
          _w = remove_instance_variable :@_width_of_quo

          s = @_scn_.string[ _d, _w ]

          if Assignment_::Mutate_value_string_for_UNmarshal[ s, & @client.listener ]
            @_string_segments.push s
            PARSING_SUCCEEDED__
          else
            PARSING_FAILED_HARD__
          end
        end

        # -- A

        def _finish_line
          if _skip_the_rest
            __init_common_results
            ACHIEVED_
          else
            whine_ :expected_end_of_line
          end
        end

        def __init_common_results

          _frozen_line = remove_instance_variable( :@_scn_ ).string.freeze

          _name_d = remove_instance_variable :@_offset_of_name_start
          _name_w = remove_instance_variable :@_width_of_name

          _value_d = remove_instance_variable :@_offset_of_value_start
          _value_w = remove_instance_variable :@_width_of_value

          @_parse_tree.accept_two_spans_and_frozen_line_(
            _name_d, _name_w, _value_d, _value_w, _frozen_line )

          remove_instance_variable :@_column_offset_

          NIL
        end

        def _skip_the_rest
          skip_ RX_THE_REST___
        end

        def __parse_name
          skip_else_ :@_width_of_name, RX_ASSIGNMENT_NAME_ do
            whine_ :expected_variable_name
          end
        end

        include TheSkipAndWhineMethods_

        def __prepare
          @_scn_ = @client.string_scanner_for_current_line_
          @_column_offset_ = 0
        end

        # ---

        # ("RHS" = right hand side)

        etc = '(?=[ ]*(?:[#;]|\r?\n?\z))'

        RX_DOUBLE_QUOTE___ = /"/
        RX_EQUALS___ = /[ ]*=/
        RX_NON_QUOTED_STRING___ = /[^ \t\r\n#;"]+(?:[ \t]+[^ \t\r\n#;"]+)*/
        RX_RHS_BOOLEAN_FALSE___ = /(?i:no|false|off)#{ etc }/
        RX_RHS_BOOLEAN_TRUE___ = /(?i:yes|true|on)#{ etc }/
        RX_RHS_INTEGER___ = /-?[0-9]+#{ etc }/
        RX_THE_REST___ = /[ ]*(?:[#;]|\r?\n?\z)/

        RX_THE_REST_OF_THE_DOUBLE_QUOTED_STRING___ = /(?:\\"|\\\\|[^"])*(?=")/
        # (note the above does a lookahead assertion on the close quote,
        # which is to say it "matches" it (sort of) but doesn't include it
        # in the matchdata :#here1. contrast with a counterpart regex somewhere..)

        etc = nil

        # ---

        # (where the below constants are used, it is useful to distinguish
        # between a parse having failed "hard" (i.e halt further procesing)
        # or a parsing having failed "softly" (i.e try something else). we
        # have tried using byte fields for the equivalent but it's not faster.)

        o = ParsingOutcome___ = ::Struct.new :failed_hard, :failed_softly, :succeeded

        PARSING_FAILED_HARD__ = o[ true, false, false ]
        PARSING_FAILED_SOFTLY__ = o[ false, true, false ]
        PARSING_SUCCEEDED__ = o[ false, false, true ]
        o = nil

        # ---
      end

      # ==
      # ==
    end
  end
end
# #history-A: broke out of central "mutable" node (spiritually) during heavy refactor
