module Skylab::Zerk

  module CLI::Table

    class Magnetics_::LineRenderer_via_Page_and_Invocation <  # 1x
        Common_::Dyadic

      # once per page, we go along every formal column we care to go along
      # (either every column of the page survey or every column ever seen,
      # depending..) and cache a cel renderer to be used for every cel in
      # that column. the end result is a function that makes lines from
      # a typified cel stream.
      #
      # this is at the center of the debate of [#050.F] ever-widening vs.
      # reclaiming-width.
      #
      # currently each technique has at least a partial code sketch.
      #
      # near [#tab-008] (a coverpoint) of narrowening pages.

      # -
        def initialize page, invo

          design = invo.design
          @_left_separator = design.left_separator
          @_inner_separator = design.inner_separator
          @_right_separator = design.right_separator

          @every_survey_of_every_field = page.every_survey_of_every_field
          @notes = invo.notes
          @page_survey = page
          @invocation = invo
        end

        def execute

          @_number_of_columns_in_this_page =
            @every_survey_of_every_field.length

          @_the_most_number_of_columns_ever_seen =
            @notes.the_most_number_of_columns_ever_seen

          grow_not_shrink = @invocation.grow_not_shrink
          grow_not_shrink || self._RIDE_HARD__shrink_is_an_incomplete_code_sketch__
          @__grow_not_shrink = grow_not_shrink

          if grow_not_shrink
            case @_the_most_number_of_columns_ever_seen <=> 1
            when -1
              _when_no_columns
            when 0
              __when_one_column_and_grow
            when 1
              __when_more_than_one_column_and_grow
            end
          else
            case @_number_of_columns_in_this_page <=> 1
            when -1
              _when_no_columns
            when 0
              __when_one_column_and_shrink
            when 1
              __when_more_than_one_column_and_shrink
            end
          end
        end

        def __when_one_column_and_grow
          p_a = _all_possible_necessary_cell_renderers_for_grow
          1 == p_a.length || fail
          _when_one_column p_a[0]
        end

        def __when_one_column_and_shrink
          p_a = _all_possible_necessary_cell_renderers_for_shrink
          1 == p_a.length || fail
          _when_one_column p_a[0]
        end

        def __when_more_than_one_column_and_grow
          _p_a = _all_possible_necessary_cell_renderers_for_grow
          _when_more_than_one_column _p_a
        end

        def __when_more_than_one_column_and_shrink
          _p_a = _all_possible_necessary_cell_renderers_for_shrink
          _when_more_than_one_column _p_a
        end

        def _when_more_than_one_column p_a

          p = p_a.fetch 0
          r = 1 ... p_a.length

          -> typi_st do
            buffer = "#{ @_left_separator }"
            buffer << p[ typi_st.gets ]
            r.each do |d|
              buffer << @_inner_separator
              buffer << p_a.fetch( d )[ typi_st.gets ]
            end
            buffer << @_right_separator
          end
        end

        def _when_one_column p
          -> typi_st do
            buffer = "#{ @_left_separator }"
            buffer << p[ typi_st.gets ]
            buffer << @_right_separator
          end
        end

        def _when_no_columns
          always_same = "#{ @_left_separator }#{ @_right_separator }".freeze
          -> typi_st do
            always_same
          end
        end

        def _all_possible_necessary_cell_renderers_for_grow

          p_a = _all_possible_necessary_cell_renderers_for_shrink

          bigger = @_the_most_number_of_columns_ever_seen
          smaller = @_number_of_columns_in_this_page

          case smaller <=> bigger
          when -1
            _yes_overage = true
          when 0
          when 1
            self._NEVER
          end

          if _yes_overage
            # (in such cases, these cels are never gonna have data)
            _r = smaller ... bigger
            _r.each do |d|
              p_a.push __build_blanker_proc_for_grow_for_field_offset d
            end
          end

          p_a
        end

        def _all_possible_necessary_cell_renderers_for_shrink

          p_a = []

          @_number_of_columns_in_this_page.times do |d|

            _fs = @every_survey_of_every_field.fetch d
            _fs || self._SANITY

            _string_via_typi =
              Magnetics_::TypifiedMixedRenderer_via_FieldSurvey.new(  # 1x
                d, _fs, @invocation ).execute

            p_a.push __safety_wrap( _string_via_typi, d )

          end
          p_a
        end

        def __safety_wrap string_via_typi, d

          # at any time ever even within one page any arbitrary mixed tuple
          # can be narrower than you expect (in terms of number of items).
          #
          # so that our pretty line-rendering functions don't have to know
          # about this, we assume that the stream there supports resulting
          # in false-ish for *multiple* calls to `gets` and we simply check
          # on every cel for true-ish here.
          #
          # (there is of course a simple pattern here: once you encounter
          # one hole you know that any remaining `gets` attempts for this
          # row will also be holes; but "optimizing" around this is almost
          # certainly a terrible idea.)
          #
          # this was or is probably :[#050.H.2].

          -> typi do
            if typi
              string_via_typi[ typi ]
            else
              _s = __cached_blank_string_for_field_offset d
              _s  # #todo
            end
          end
        end

        def __build_blanker_proc_for_grow_for_field_offset d
          always_this = _build_blank_string_for_grow_for_field_offset d
          -> typi do
            typi && self._SANITY
            always_this
          end
        end

        def __cached_blank_string_for_field_offset d
          a = ( @___cached_blank_strings ||= [] )
          s = a[ d ]
          if ! s
            s = __build_blank_string_for_field_offset d
            a[ d ] = s
          end
          s
        end

        def __build_blank_string_for_field_offset d
          if @__grow_not_shrink
            _build_blank_string_for_grow_for_field_offset d
          else
            __build_blank_string_for_shrink_for_field_offset d
          end
        end

        def _build_blank_string_for_grow_for_field_offset d
          _fn = @notes.dereference_for_field d
          _w = _fn.widest_width_ever
          ( SPACE_ * _w ).freeze
        end

        def __build_blank_string_for_shrink_for_field_offset d
          _fs = @every_survey_of_every_field.fetch d
          _w = _fs.width_of_widest_string
          ( SPACE_ * _w ).freeze
        end

      # -

      # ==

      # ==
    end
  end
end
# #born: broke out of sole client
