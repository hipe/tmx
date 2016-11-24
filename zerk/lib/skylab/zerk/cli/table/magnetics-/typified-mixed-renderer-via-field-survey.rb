module Skylab::Zerk

  module CLI::Table

    class Magnetics_::TypifiedMixedRenderer_via_FieldSurvey

      # for this centralest of features of this sub-library (lining up
      # columns), we tend to rely on this general techinque: taking into
      # account what *will be* the widest width of any content once
      # stringified in the column, produce a formatting string for use by
      # `String#%` tailor made to the "type" of the particular value
      # (different types can occur in the same column), and whether the
      # column is align left or right.
      #
      # this technique (or one like it) has been the central feature of the
      # many libraries in this strain since their beginning (and it predates
      # this file by years and years). but new in this version:
      #
      #   - we arrive at a pre-calculation of how much width particular
      #     values will need as strings without actually converting them
      #     to strings, through a technique we call "a priori inference"
      #     explained in the next section.
      #
      #     this technique replaces an older technique that had a higher
      #     cost of memory and processing: in the old way we would in one
      #     pass traverse the whole page converting each value to string
      #     "early", and by noting the width of each value-as-string we
      #     would determine what is the widest of these strings. then after
      #     this maximum is found we would "flush" the matrix for a final
      #     pass, converting these values-as-strings (somehow) to space-
      #     padded strings in a final rendering pass.
      #
      #     this technique required that we store that whole matrix (page)
      #     of values-as-strings in memory while we gathered the maximum
      #     widths for use in generating cel-renderers for a final pass,
      #     which is now seen as unnecessarily wasteful. (imagine a large
      #     matrix of booleans or floats, for example, all being stored
      #     in memory as strings.)
      #
      #     in the new technique this intermediate storage of strings is
      #     avoided - the matrix is instead one of "typified mixed values",
      #     where all we store in the matrix is the value tupled with a
      #     symbol about its type. because we can predict (or, to the extent
      #     that we can predict) the width of the content string before we
      #     actually make the string, the value is never actually converted
      #     to to a string until it is actually rendered and immediately
      #     produced as a streamed item.
      #
      #
      #   - this is the first application of this general techinque
      #     made to be compatible with #paging. (#todo some details are
      #     not preserved across the page boundary still, and we may leave
      #     it that way..)
      #
      #
      # ## a priori string width inference overview
      #
      # here's a summary of our "a priori inference" technique per type to
      # predict the necessary width withot converting it to a string:
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
      #   | nonzero float   | this one's a little scarier but we have a
      #   |                 |   function that seems to work next to above.
      #   |                 |
      #   | boolean         | this one's, well, pragmatic (see code).
      #   |                 |
      #   | nil             | the content itself is always zero-width.
      #   |                 |   (or we could do it like `true`/`false`)
      #   |                 |
      #   | other           | we don't care about supporting arbitrary
      #   |                 |   objects here. that's seen as out of scope.
      #
      #  :#table-spot-1.

      # -

        def initialize d, fs, notes, design

          @field_note = notes.for_field d

          @design = design
          @field_survey = fs
          @notes = notes
        end

        def execute

          fn = @field_note
          fs = @field_survey

          w = fn.widest_width_ever
          w_ = fs.width_of_widest_string

          if w < w_
            fn.widest_width_ever = w_
            # #open [#050] this "widening" was the central mechanical
            # innovation of (there). eventually DRY up that with this.
          end

          _1 = @notes.do_display_header_row
          _2 = fs.number_of_symbols.nonzero?
          _3 = fs.number_of_strings.nonzero?

          _do_stringishes = _1 || _2 || _3

          @proc_box = Common_::Box.new

          # (do numerics before all others because #here-1)

          if fs.number_of_numerics.nonzero?
            _visit_maven :TypeMaven_for_Numerics
          end

          if _do_stringishes
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

          value_renderer_via_type = remove_instance_variable( :@proc_box ).h_

          -> typi do
            value_renderer_via_type.fetch( typi.typeish_symbol )[ typi.value ]
          end
        end

        def _visit_maven const
          This_.const_get( const, false ).new( self ).execute
          NIL
        end

        def is_align_left_explicitly
          @design.field_is_aligned_left_explicitly @field_note.field_offset
        end

        def is_align_right_explicitly
          @design.field_is_aligned_right_explicitly @field_note.field_offset
        end

        def widest_width_ever
          @field_note.widest_width_ever
        end

        def on sym, & p
          @proc_box.add sym, p ; nil
        end

        attr_reader(
          :design,
          :field_note,
          :field_survey,
          :proc_box,
        )
      # -
      # ==

      class TypeMaven_for_Numerics

        def initialize _
          @_ = _
        end

        def execute

          fs = @_.field_survey

          @_left_width = fs.
            the_maximum_number_of_characters_ever_seen_left_of_the_decimal

          @_right_width = fs.
            the_maximum_number_of_digits_ever_seen_to_the_right_of_the_decimal

          @_widest_width = fs.width_of_widest_string

          seen_ints = fs.number_of_nonzero_integers.nonzero?
          seen_floats = @_right_width.nonzero?
          seen_zeros = fs.number_of_zeros.nonzero?

          if seen_floats

            __contribute_handler_for_floats

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

        def __contribute_handler_for_floats

          my_width = @_left_width + 1 + @_right_width  # 1 for '.'

          _inner_format = "%#{ my_width }.#{ @_right_width }f"

          float_format = _pad_with_spaces_default_align_right my_width, _inner_format

          @_.on :nonzero_float do |f|

            _ = float_format % f

            # hack to remove trailing zeros while still using `format` :(

            _ = _.gsub %r((?<!\.)(0+)\z) do |hi|  # #open [#bm-012] (in [sl])
              SPACE_ * hi.length
            end
            _
          end
        end

        def __contribute_handler_for_ints_with_invisible_floating_point

          width_of_right_part = 1 + @_right_width   # 1 for '.'

          _my_width = @_left_width + width_of_right_part

          _spaces_instead_of_decimal_etc = SPACE_ * width_of_right_part

          _inner_format = "%#{ @_left_width }d#{ _spaces_instead_of_decimal_etc }"

          int_format = _pad_with_spaces_default_align_right _my_width, _inner_format

          @_.on :nonzero_integer do |d|
            int_format % d
          end
        end

        def __contribute_handler_for_ints_simply

          my_width = @_left_width

          _inner_format = "%#{ my_width }d"

          int_format = _pad_with_spaces_default_align_right my_width, _inner_format

          @_.on :nonzero_integer do |d|
            int_format % d
          end
        end

        def __contribute_static_string_handler_for_zeros

          static_string = _pad_with_spaces_default_align_right 1, '0'

          @_.on :zero do
            ::Kernel._K
            static_string
          end
        end

        def __reuse_handler_for_floats_as_handler_for_zeros

          @_.on :zero, & @_.proc_box.fetch( :nonzero_float )
        end

        def _reuse_handler_for_ints_as_handler_for_zeros

          @_.on :zero, & @_.proc_box.fetch( :nonzero_integer )
        end

        def _pad_with_spaces_default_align_right width_of_inner_string, inner_string

          # NOTE that the would-be width of the formatted string (which is
          # expressed as the first argument above) CAN BE wider than the
          # "widest width ever" seen to date - imagine 1.11 and 22.2:
          # each of those says (correctly) that its value-as-string width
          # is 4. however, if you stack them atop one another and line up
          # the decimals, your column needs to be 5 characters wide:
          #    -----
          #     1.11
          #    22.20
          #    -----
          # so when floats are in play, the width needed is the sum
          # of the widest width ever seen for a left part plus the widest
          # width ever seen for a right part. whew!  :#here-1

          w = @_.widest_width_ever
          case w <=> width_of_inner_string
          when -1
            # push the width wider. no extra padding here.

            @_.field_note.widest_width_ever = width_of_inner_string
            inner_string

          when 0
            # no extra padding. widest width ever is correct as-is
            inner_string

          when 1
            # the sum of (blah blah) is still narrower than the widest
            # width ever, so we pad. effect the fact that for numbers, we
            # align right by default and align left only if specified
            # explicitly. (it's the opposite for the string-ishes.)

            padding = SPACE_ * ( w - width_of_inner_string )

            if @_.is_align_left_explicitly
              "#{ inner_string }#{ padding }"
            else
              "#{ padding }#{ inner_string }"
            end
          end
        end
      end

      # ==

      This_ = self
    end
  end
end
# #born: freshfaced and new for unification, but an in-spirit rewrite of legacy
