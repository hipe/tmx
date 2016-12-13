module Skylab::Zerk

  module CLI::Table

    class Magnetics_::TypifiedMixedRenderer_via_FieldSurvey  # 1x

      # for this centralest of features of this sub-library (lining up
      # columns), we tend to rely on this general techinque: taking into
      # account what *will be* the widest width of any content once
      # stringified in the column (this (sometimes hypothetical) string
      # being called the "value-as-string"), we produce a formatting string
      # for use by `String#%` (same as `Kernel#sprintf`) that
      #
      #   - expresses the align-left or align-right-ness of the column AND
      #
      #   - is tailor made to the "type" of the particular value
      #     (different types can occur in the same column)
      #
      # this technique (or one like it) has been the central feature of the
      # many libraries in this strain since their beginning (and it predates
      # this file by years and years). but new in this version:
      #
      #   - this is the first application of this general techinque
      #     made to be compatible with #paging. (#todo some details are
      #     not preserved across the page boundary still, and we may leave
      #     it that way..)
      #
      #   - our whole rendering pipeline has been both simplified and made
      #     universal, so that it uses less memory that the old way (one of
      #     them, anyway) but still facilitates our complete panoply of
      #     "advanced" features.
      #
      # a detailed justification of the new rendering pipeline starts at
      # [#050.C] "justification of the new way". there too can be found
      # an explanation of same.
      #
      # the next section is the lowest level detail of that rearchitecting,
      # directly relevant to the code in this node.

      # ## a priori string width inference overview :#table-spot-2
      #
      # here's a summary of our "a priori inference" technique per type to
      # predict the necessary width without converting it to a string:
      #
      #   |  type-ish       |  how we infer the would-be string width
      #   |=                |
      #   | string          | N/A - the string is already a string so
      #   |                 |   we already know its width-as-string.
      #   |                 |
      #   | symbol          | thank goodness ruby gives us `Symbol#length`,
      #   |                 |   otherwise this whole algo might have to change.
      #   |                 |
      #   | nonzero integer | the "divide by ten until it's zero" technique
      #   |                 |   counts the number of digits (in [ba] Number).
      #   |                 |   + 1 if it's negative (for the '-' character).
      #   |                 |
      #   | nonzero float   | this one's a little scarier in two regards, but
      #   |                 |  1) we have a function in [ba] that we *think*
      #   |                 |  overcomes a well-known problem and 2) #table-spot-3
      #   |                 |
      #   | boolean         | this one's, well, pragmatic (see code).
      #   |                 |
      #   | nil             | the "string-as-value" is always the empty
      #   |                 | string. (or we could do it like `true`/`false`)
      #   |                 |
      #   | other           | we don't care about supporting arbitrary
      #   |                 |   objects here. that's seen as out of scope.
      #
      #  :#table-spot-1.

      ClientMethods__ = ::Module.new

      # -

        include ClientMethods__

        def initialize d, fs, invo

          @_session_ = ClientSession___.new d, fs, invo

          @field_survey = fs

          @__do_display_header_row = invo.design.do_display_header_row
        end

        def execute

          __maybe_widen_field_note_width

          fs = @field_survey

          if fs.number_of_numerics.nonzero?
            TypeMaven_for_Numerics___.new( @_session_ ).execute
          end

          if __do_stringishes
            __contribute_renderer_for_stringishes
          end

          if fs.number_of_booleans.nonzero?
            __contribute_renderer_for_booleans
          end

          if fs.number_of_nils.nonzero?
            __contribute_renderer_for_nils
          end

          if fs.number_of_others.nonzero?
            self._COVER_ME
          end

          __flush_final_proc
        end

        def __maybe_widen_field_note_width

          # the field survey pertains only to this page but the field note
          # is forever. we haven't yet widened the one with the other; we
          # do it here. :#table-spot-6
          #
          # it goes in the one direction but not the other (the survey
          # writes to the notes), so we've got to be sure that we only read
          # the note and not the survey after here.
          #
          # this "widening" across pages was the central mechanical innovation
          # of [tagged]. eventually we'll dry that up with this. :[#050].

          now = @field_survey.width_of_widest_string

          fn = @_session_.field_note

          ever = fn.widest_width_ever

          if ever < now
            fn.widest_width_ever = now
          end
          NIL
        end

        def __do_stringishes

          # for sanity check, maintain contact with all of them

          _2 = @field_survey.number_of_symbols.nonzero?

          _3 = @field_survey.number_of_strings.nonzero?

          @__do_display_header_row || _2 || _3
        end

        def __contribute_renderer_for_stringishes

          _w = widest_width_ever

          _is_right = is_align_right_explicitly

          format = "%#{ DASH_ unless _is_right }#{ _w }s"

          on :string do |s|
            format % s
          end
        end

        def __contribute_renderer_for_booleans

          # normally align right (unlike strings)

          if is_align_left_explicitly
            _minus = DASH_
          end

          format = "%#{ _minus }#{ widest_width_ever }s"

          ocd_true = format % 'true'
          ocd_false = format % 'false'

          on :boolean do |yn|
            yn ? ocd_true : ocd_false
          end
        end

        def __contribute_renderer_for_nils

          spacer_string = SPACE_ * widest_width_ever

          on :nil do
            spacer_string
          end
          NIL
        end

        def __flush_final_proc

          value_renderer_via_type = @_session_.__release_proc_box_.h_

          -> typi do
            value_renderer_via_type.fetch( typi.typeish_symbol )[ typi.value ]
          end
        end
      # -

      class TypeMaven_for_Numerics___

        include ClientMethods__

        def execute

          # (this is what we mean by "combinatorial..)

          if seen_floats

            if custom_float_format_was_used
              __use_custom_handler_for_floats
            else
              __contribute_generated_handler_for_floats
            end

            if seen_ints

              __contribute_handler_for_ints_with_invisible_floating_point

              if seen_zeros
                _reuse_handler_for_ints_as_handler_for_zeros
              end
            elsif seen_zeros
              __reuse_handler_for_floats_as_handler_for_zeros
            end
          elsif seen_ints
            __contribute_handler_for_ints_simply

            if seen_zeros
              _reuse_handler_for_ints_as_handler_for_zeros
            end
          elsif seen_zeros
            __contribute_static_string_handler_for_zeros
          end
          NIL
        end

        def __use_custom_handler_for_floats

          UseCustomHandlerForFloats__.new( @_session_ ).execute
        end

        def __contribute_generated_handler_for_floats

          NonzeroFloatMaven___.new( @_session_ ).execute
        end

        def __contribute_handler_for_ints_with_invisible_floating_point

          NonzeroIntegerWithInvisibleFloatingPoint___.new( @_session_ ).execute
        end

        def __contribute_handler_for_ints_simply

          NonzeroIntegerMaven___.new( @_session_ ).execute
        end

        def __reuse_handler_for_floats_as_handler_for_zeros

          on :zero, & proc_box.fetch( :nonzero_float )
        end

        def _reuse_handler_for_ints_as_handler_for_zeros

          on :zero, & proc_box.fetch( :nonzero_integer )
        end

        def __contribute_static_string_handler_for_zeros

          ::Kernel._COVER_ME_code_sketch

          static_string = pad_with_spaces_default_align_right 1, '0'

          on :zero do
            static_string
          end
        end
      end

      # ==

      NumericMaven__ = ::Class.new

      class UseCustomHandlerForFloats__ < NumericMaven__

        def _proc_

          # it's entirely possible that the strings produced by a custom
          # format are narrower than value-as-strings produced for values
          # of other types in the column. if we detect that this is the
          # case, we "widen" this strange format (more correctly we attempt
          # to widen the strings it produces) the same way we do elsewhere
          # here when working with our natively generated format strings.
          # this is the only place where we assume that a strange "format"
          # is a string..

          fs = @_session_.field_survey

          format = fs.CUSTOM_FLOAT_FORMAT

          w = fs.WIDTH_OF_VALUE_AS_STRING_FROM_CUSTOM_FLOAT_FORMAT

          use_format = if w < widest_width_ever
            pad_with_spaces_default_align_right w, format
          else
            format
          end

          -> float_or_integer do
            use_format % float_or_integer
          end
        end

        def _name_symbol_
          :nonzero_float
        end
      end

      class NonzeroFloatMaven___ < NumericMaven__

        def _proc_

          float_format = _final_format_string_

          -> f do
            _ = float_format % f

            # hack to remove trailing zeros while still using `format` :(

            _ = _.gsub %r((?<!\.)(0+)\z) do |hi|  # #open [#bm-012] (in [sl])
              SPACE_ * hi.length
            end
            _  # #todo
          end
        end

        def _inner_format_string_

          _right_width = widest_right_in_field_survey

          "%#{ _width_of_imaginary_content_column_ }.#{ _right_width }f"
        end

        def _width_of_imaginary_content_column_
          @_session_.field_survey.width_of_imaginary_content_column_
        end

        def _name_symbol_
          :nonzero_float
        end
      end

      # ==

      class NonzeroIntegerWithInvisibleFloatingPoint___ < NumericMaven__

        def _proc_

          if custom_float_format_was_used
            __proc_wickedly
          else
            __proc_normally
          end
        end

        def __proc_wickedly

          fs = @_session_.field_survey

          left_w = widest_left_in_field_survey

          canary_d = 10 ** ( left_w.zero? ? 1 : left_w - 1 )

          formatted_s = fs.CUSTOM_FLOAT_FORMAT % canary_d
          formatted_w = formatted_s.length

          one = '1'
          pos = formatted_s.index one
          pos_ = formatted_s.index one
          pos == pos_ || self._HACK_FAILED  # #todo

          _head_space = SPACE_ * pos

          _tail_space = SPACE_ * ( formatted_w - pos - left_w )

          _inner_format = "#{ _head_space }%#{ left_w }d#{ _tail_space }"

          int_format = pad_with_spaces_default_align_right formatted_w, _inner_format

          -> d do

            int_format % d
          end
        end

        def __proc_normally

          left_width = widest_left_in_field_survey

          right_width = 1 + widest_right_in_field_survey  # 1 for '.'

          _my_width = left_width + right_width

          _spaces_instead_of_decimal_etc = SPACE_ * right_width

          _inner_format = "%#{ left_width }d#{ _spaces_instead_of_decimal_etc }"

          int_format = pad_with_spaces_default_align_right _my_width, _inner_format

          -> d do
            int_format % d
          end
        end

        def _name_symbol_
          :nonzero_integer  # a repeat
        end
      end

      # ==

      class NonzeroIntegerMaven___ < NumericMaven__

        def _proc_

          format = _final_format_string_

          -> d do
            format % d
          end
        end

        def _inner_format_string_

          _w = widest_left_in_field_survey

          "%#{ _w }d"
        end

        def _width_of_imaginary_content_column_
          widest_left_in_field_survey  # ..
        end

        def _name_symbol_
          :nonzero_integer
        end
      end

      # ==

      class NumericMaven__

        include ClientMethods__

        def execute
          _p = _proc_
          _k = _name_symbol_
          on _k, & _p
          NIL
        end

        def _final_format_string_

          _w = _width_of_imaginary_content_column_

          _s = _inner_format_string_

          pad_with_spaces_default_align_right _w, _s
        end
      end

      # ==

      module ClientMethods__

        def initialize sess  # ..
          @_session_ = sess
        end

        def pad_with_spaces_default_align_right width_of_inner_string, inner_string

          w = widest_width_ever
          case w <=> width_of_inner_string
          when -1

            self._NEVER  # see #table-spot-3

          when 0
            # no extra padding. widest width ever is correct as-is
            inner_string

          when 1
            # the sum of (blah blah) is still narrower than the widest
            # width ever, so we pad. effect the fact that for numbers, we
            # align right by default and align left only if specified
            # explicitly. (it's the opposite for the string-ishes.)

            padding = SPACE_ * ( w - width_of_inner_string )

            if is_align_left_explicitly
              "#{ inner_string }#{ padding }"
            else
              "#{ padding }#{ inner_string }"
            end
          end
        end

        def widest_width_ever
          @_session_.field_note.widest_width_ever
        end

        def widest_left_in_field_survey  # ..
          @_session_.field_survey.
            the_maximum_number_of_characters_ever_seen_left_of_the_decimal
        end

        def widest_right_in_field_survey  # ..
          @_session_.field_survey.
            the_maximum_number_of_digits_ever_seen_to_the_right_of_the_decimal
        end

        def is_align_left_explicitly
          @_session_.__is_align_left_explicitly_
        end

        def is_align_right_explicitly
          @_session_.__is_align_right_explicitly_
        end

        def custom_float_format_was_used
          @_session_.field_survey.CUSTOM_FLOAT_FORMAT_WAS_USED
        end

        def seen_floats
          @_session_.field_survey.number_of_nonzero_floats.nonzero?
        end

        def seen_ints
          @_session_.field_survey.number_of_nonzero_integers.nonzero?
        end

        def seen_zeros
          @_session_.field_survey.number_of_zeros.nonzero?
        end

        def on sym, & p
          @_session_.proc_box.add sym, p ; nil
        end

        def proc_box
          @_session_.proc_box
        end
      end

      class ClientSession___

        def initialize d, fs, invo
          @proc_box = Common_::Box.new
          design = invo.design
          @design = design
          @field_design = design.for_field d
          @field_note = invo.notes.for_field d
          @field_survey = fs
        end

        def make_field_note_width_wider now  # CAREFUL
          @field_note.widest_width_ever = now
          NIL
        end

        def __is_align_left_explicitly_
          @design.field_is_aligned_left_explicitly @field_note.defined_field_offset
        end

        def __is_align_right_explicitly_
          @design.field_is_aligned_right_explicitly @field_note.defined_field_offset
        end

        def __release_proc_box_
          remove_instance_variable :@proc_box
        end

        attr_reader(
          :field_design,
          :field_note,
          :field_survey,
          :proc_box,
        )
      end

      # ==

      This_ = self
    end
  end
end
# #born: freshfaced and new for unification, but an in-spirit rewrite of legacy
