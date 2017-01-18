module Skylab::DocTest

  class AssetDocumentReadMagnetics_::RunStream_via_CommentBlock < Common_::Monadic

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

      # (note there is some logical redundancy below because we're still not
      #  sure whether we will ever want to know the indent level when we
      #  create the discussion run.)

      # consume leading blanks
      blanks = nil
      while @_line_is_blank
        ( blanks ||= [] ).push _release_blank_line
        _step
        @_reached_end_of_input && break
      end

      if @_reached_end_of_input  # edge case - all lines blank (#coverpoint1-9)

        _init_empty_discussion_run
        blanks.each do |o|
          @_discussion_run.accept_line_object o
        end
        @_state = :_nothing
        _release_discussion_run
      else
        # assume is not blank. we have the first line with content in
        # the comment block. per

        @_INDENT_LEVEL = @_content_range.begin
        _init_empty_discussion_run
        if blanks
          blanks.each do |o|
            @_discussion_run.accept_line_object o
          end
        end
        _finish_and_release_discussion_run
      end
    end

    def _finish_and_release_non_first_discussion_run
      _init_empty_discussion_run
      _finish_and_release_discussion_run
    end

    def _init_empty_discussion_run

      @_discussion_run = Home_::Models_::Discussion::Run.new_empty__ ; nil
    end

    def _finish_and_release_discussion_run  # mentor (template, even) to #here

      # assume you have a current line that is a discussion line..

      @_discussion_run.accept_line_via_offsets( * _release_discussion_line_args )

      # while there are more lines and the line is a discussion line, same.

      begin

        _step

        if @_reached_end_of_input
          @_state = :_nothing
          break
        end

        if @_line_is_blank  # #coverpoint1-1
          @_discussion_run.accept_line_object _release_blank_line
          redo
        end

        @_this_indent_level = @_content_range.begin

        @_indent_delta = @_this_indent_level - @_INDENT_LEVEL

        d = 0 <=> @_indent_delta

        if NO_CHANGE_IN_INDENT__ != d

          if INDENT_HAS_INCREASED__ == d

            if INDENT_THRESHOLD__ <= @_indent_delta
              @_state = :_finish_and_release_code_run
              break
            end
            # (when indentation increased but not by enough to reach
            #  threshold, push indent level inwards #coverpoint1-2)
          else
            INDENT_HAS_DECREASED__ == d || Home_._SANITY  # #coverpoint1-4
          end
          _accept_new_indent_level
        end

        @_discussion_run.accept_line_via_offsets( * _release_discussion_line_args )
        redo
      end while nil

      _clear_these
      _release_discussion_run
    end

    def _release_discussion_run
      remove_instance_variable( :@_discussion_run ).finish__
    end

    def _finish_and_release_code_run  # very close mentee of #here

      # assume you have a current line that is a code line..

      cr = Home_::Models_::Code::Run.begin_via_offsets__( * _release_code_line_args )

      # while there are more lines and the line is a code line, keep going

      begin

        _step

        if @_reached_end_of_input
          @_state = :_nothing
          break
        end

        if @_line_is_blank  # #coverpoint1-6
          cr.accept_line_object _release_blank_line
          redo
        end

        @_this_indent_level = @_content_range.begin

        @_indent_delta = @_this_indent_level - @_INDENT_LEVEL

        d = 0 <=> @_indent_delta

        if NO_CHANGE_IN_INDENT__ != d

          if INDENT_HAS_INCREASED__ == d

            if INDENT_THRESHOLD__ <= @_indent_delta  # #coverpoint1-5
              cr.accept_line_via_offsets( * _release_code_line_args )
              redo
            end
          else
            INDENT_HAS_DECREASED__ == d || Home_._SANITY
          end
          _accept_new_indent_level
        end

        @_state = :_finish_and_release_non_first_discussion_run
        break
      end while nil

      _clear_these
      cr.finish
    end

    def _accept_new_indent_level
      @_INDENT_LEVEL = @_this_indent_level
    end

    def _clear_these
      @_indent_delta = nil ; remove_instance_variable :@_indent_delta
      @_this_indent_level = nil ; remove_instance_variable :@_this_indent_level
    end

    INDENT_THRESHOLD__ = 4
    INDENT_HAS_DECREASED__ = 1
    INDENT_HAS_INCREASED__ = -1
    NO_CHANGE_IN_INDENT__ = 0

    def _release_code_line_args
      _remove_these_ivars
      [
        remove_instance_variable( :@_margin_range ),
        remove_instance_variable( :@_content_range ),
        remove_instance_variable( :@_LTS_range ),
        remove_instance_variable( :@_string ),
      ]
    end

    def _release_discussion_line_args
      _remove_these_ivars
      [
        remove_instance_variable( :@_margin_range ),
        remove_instance_variable( :@_content_range ),
        remove_instance_variable( :@_LTS_range ),
        remove_instance_variable( :@_string ),
      ]
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
        alias_method :via_offsets__, :new  # #testpoint
        undef_method :new
      end  # >>

      def initialize margin_r, _LTS_r, s

        @_LTS_range = _LTS_r
        @_margin_range = margin_r
        @string = s
      end

      def to_line_stream
        Common_::Stream.via_item get_content_line
      end

      def get_content_line  # a bit of a misnomer, be careful
        @string[ @_margin_range.end ... @_LTS_range.end ]
      end

      attr_reader(
        :string,
      )

      def has_magic_copula
        false
      end

      def is_blank_line
        true
      end
    end

    Range__ = -> a do
      ::Range.new( * a, true )
    end
  end
end
