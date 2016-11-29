module Skylab::Zerk

  module CLI::Table

    class Magnetics_::TableWidth_via_PageSurvey

      # our formula for determining table width is probably:
      #
      #     width of left separator +
      #
      #     the width of every field +
      #
      #     ( 2 > num fields ? 0 : ( num fields - 1 * width of inner separator )
      #
      #     width of right separator
      #

      # (the name of this magnetic is not accurate but is meant to sound
      # more obvious and literate than if it had a more literal name.)

      class << self
        def call * a
          new( * a ).execute
        end
        alias_method :[], :call
        private :new
      end  # >>

      def initialize page_surveyish, design
        @design = design
        @page_surveyish = page_surveyish
      end

      def execute

        @_total = 0

        _add_width_of_any_string @design.left_separator

        scn = @page_surveyish.to_field_survey_scanner

        _add_the_width_of_this_field_survey scn.current_token

        add_width_for_separator = __proc_to_add_width_for_inner_separator

        begin

          scn.advance_one

          if scn.no_unparsed_exists
            break
          end

          add_width_for_separator[]

          _add_the_width_of_this_field_survey scn.current_token

          redo
        end while above

        _add_width_of_any_string @design.right_separator

        @_total
      end

      def _add_the_width_of_this_field_survey fs

        if fs.number_of_cels.zero?
          fs.width_of_widest_string.zero? || fs._SANITY  # #todo
        else
          d = fs.width_of_widest_string
          d.nonzero? || fs._SANITY  # todo
          @_total += d
        end
        NIL
      end

      def __proc_to_add_width_for_inner_separator

        s = @design.inner_separator
        if s
          sep_d = s.length
        end
        if sep_d && sep_d.nonzero?
          -> { @_total += sep_d }
        else
          EMPTY_P_
        end
      end

      def _add_width_of_any_string s
        if s
          @_total += s.length
        end
      end
    end
  end
end
# #history: broke out into own node for SRP during unification. algo is years old
