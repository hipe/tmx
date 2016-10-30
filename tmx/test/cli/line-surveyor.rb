module Skylab::TMX::TestSupport

  module CLI

    class LineSurveyor

      # (abstracted from *one* test that used to be function soup)

      def initialize
        yield self
        freeze
      end

      attr_writer(
        :every_other_line_must_look_like_this,
        :one_line_must_look_like_this,
      )

      def to_survey
        Survey___.new(
          @one_line_must_look_like_this,
          @every_other_line_must_look_like_this,
        )
      end

      # ==

      class Survey___

        def initialize p, p_
          @total_line_count = 0
          @_one_line_must_look_like_this = p
          @_every_other_line_must_look_like_this = p_
          @_see_line = :__see_line_while_still_searching
        end

        def see_line line
          @total_line_count += 1
          send @_see_line, line
        end

        def __see_line_while_still_searching line

          _yes = @_one_line_must_look_like_this[ line ]
          if _yes
            @did_find = true
            @_see_line  = :_see_line_normally
          else
            _see_line_normally line
          end
          NOTHING_  # to accord with [ze] fail early, tell parser "keep parsing"
        end

        def _see_line_normally line
          _yes = @_every_other_line_must_look_like_this[ line ]
          if ! _yes
            ( @strange_lines ||= [] ).push line
          end
          NOTHING_  # same as above
        end

        def finish
          remove_instance_variable :@_one_line_must_look_like_this
          remove_instance_variable :@_every_other_line_must_look_like_this
          remove_instance_variable :@_see_line
          freeze
        end

        attr_reader(
          :did_find,
          :strange_lines,
          :total_line_count,
        )
      end
      # ==
    end
  end
end
# #born: abstracted from ONE test that was function soup
