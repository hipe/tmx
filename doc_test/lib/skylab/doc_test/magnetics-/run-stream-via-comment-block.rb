module Skylab::DocTest

  class Magnetics_::RunStream_via_CommentBlock < Common_::Actor::Monadic

    # three laws (more or less) by its tests which are by [#021]

    def initialize cb
      @matchdata_stream = cb.to_line_matchdata_stream__
    end

    def execute
      @_state = :__first_run
      Common_.stream do
        send @_state
      end
    end

    def __first_run

      md = @matchdata_stream.gets
      @_reached_end_of_input = false  # all comment blocks have at least one

      @_pound_end_charpos = md.offset( 0 ).last  # will be same for each line
      _measure md

      # consume leading blanks
      blanks = nil
      @_line_is_blank and self._COVER_THIS
      while @_line_is_blank
        ( blanks ||= [] ).push _release_blank_line
        _step
        @_reached_end_of_input && break
      end

      if @_reached_end_of_input

        self._COVER_ME_read_this_all_lines_were_blank_do_something_with_state
        # this is an edge case - all lines were blank..
      else
        # assume is not blank. we have the first line with content in
        # the comment block. per

        @_INDENT_LEVEL = @_content_range.begin
        _init_empty_discussion_run
        if blanks
          blanks.each do |o|
            @_discussion_run.accept_line o
          end
        end
        _finish_and_release_discussion_run
      end
    end

    def __finish_and_release_non_first_discussion_run

      _init_empty_discussion_run
      _finish_and_release_discussion_run
    end

    def _init_empty_discussion_run

      @_discussion_run = Models_::Discussion::Run.new_empty__ ; nil
    end

    def _finish_and_release_discussion_run

      @_discussion_run.accept_line _release_discussion_line
      begin
        _step

        if @_reached_end_of_input
          @_state = :_nothing
          break
        end

        if @_line_is_blank  # #coverpoint-1
          @_discussion_run.accept_line _release_blank_line
          redo
        end

        this_indent_level = @_content_range.begin

        indent_delta = this_indent_level - @_INDENT_LEVEL
        case 0 <=> indent_delta

        when NO_CHANGE_IN_INDENT__

          @_discussion_run.accept_line _release_discussion_line
          redo

        when INDENT_HAS_INCREASED__

          if INDENT_THRESHOLD__ <= indent_delta
            @_state = :_finish_and_release_code_run
            break
          end

          # when indentation increased but not by enough to reach threshold,
          # this pushes the indent level inwards (#coverpoint-2).

          @_INDENT_LEVEL = this_indent_level
          @_discussion_run.accept_line _release_discussion_line
          redo

        when INDENT_HAS_DECREASED__

          ::Kernel._WHEN_indentation_has_decreased_then_um_ETC
        else

          ::Kernel._WONT_COVER
        end

        ::Kernel._WONT_COVER
      end while nil

      remove_instance_variable( :@_discussion_run ).finish__
    end

    def _finish_and_release_code_run

      # assume you have a current line that is a code line..
      _remove_these_ivars

      cr = Models_::Code::Run.begin_via_offsets__( * _release_code_line_vals )

      # while there are more lines and the line is a code line, keep going

      begin

        _step

        if @_reached_end_of_input
          @_state = :_nothing
          cr = cr.finish
          break
        end

        if @_line_is_blank
          ::Kernel._K_probably_fine_RIDE_THIS
          cr.accept_line _release_blank_line
          redo
        end

        # EXPERIMENTALLY we are using the same template as the other mode:

        indent_delta = @_content_range.begin - @_INDENT_LEVEL
        case 0 <=> indent_delta

        when NO_CHANGE_IN_INDENT__

          ::Kernel._K_MODE_CHANGE

        when INDENT_HAS_INCREASED__

          if INDENT_THRESHOLD__ <= indent_delta
            ::Kernel._K_STILL_CODE
            break
          end

          @_state = :__finish_and_release_non_first_discussion_run
          break

        when INDENT_HAS_DECREASED__

          ::Kernel._K
        else

          ::Kernel._WONT_COVER
        end

        ::Kernel._WONT_COVER

        # assume nonblank line. how does indent compare?

      end while nil

      cr
    end

    INDENT_THRESHOLD__ = 4
    INDENT_HAS_DECREASED__ = 1
    INDENT_HAS_INCREASED__ = -1
    NO_CHANGE_IN_INDENT__ = 0

    def _release_code_line_vals
      [
        remove_instance_variable( :@_margin_range ),
        remove_instance_variable( :@_content_range ),
        remove_instance_variable( :@_LTS_range ),
        remove_instance_variable( :@_string ),
      ]
    end

    def _release_discussion_line
      _remove_these_ivars
      Models_::Discussion::Line.via_offsets__(
        remove_instance_variable( :@_margin_range ),
        remove_instance_variable( :@_content_range ),
        remove_instance_variable( :@_LTS_range ),
        remove_instance_variable( :@_string ),
      )
    end

    def _release_blank_line
      _remove_these_ivars
      Blank_Line___.via_offsets__(
        remove_instance_variable( :@_margin_range ),
        remove_instance_variable( :@_LTS_range ),
        remove_instance_variable( :@_string ),
      )
    end

    def _remove_these_ivars
      remove_instance_variable :@_line_is_blank
      remove_instance_variable :@_reached_end_of_input ; nil
    end

    def _step

      md = @matchdata_stream.gets
      if md
        @_reached_end_of_input = false
        _measure md
      else
        @_reached_end_of_input = true
      end
      NIL_
    end

    def _measure md

      s = md.string
      md_ = RX___.match s, @_pound_end_charpos

      @_margin_range = Range__[ md_.offset( :margin ) ]
      @_content_range = Range__[ md_.offset( :content ) ]
      @_LTS_range = Range__[ md_.offset( :line_termination_sequence ) ]

      @_line_is_blank = @_content_range.size.zero?
      @_string = s
      NIL_
    end

    def _nothing
      NOTHING_
    end

    RX___ = /\G
      (?<margin>[\t ]*)
      (?<content>.*)$
      (?<line_termination_sequence>[\n\r]*)
    \z/x

    # ==

    class Blank_Line___

      class << self
        alias_method :via_offsets__, :new
        undef_method :new
      end  # >>

      def initialize margin_r, _LTS_r, s

        @_LTS_range = _LTS_r
        @_margin_range = margin_r
        @_string = s
      end

      def string___  # #testpoint-only
        @_string
      end

      def is_blank_line  # #todo
        true
      end
    end

    Range__ = -> a do
      ::Range.new( * a, true )
    end
  end
end
