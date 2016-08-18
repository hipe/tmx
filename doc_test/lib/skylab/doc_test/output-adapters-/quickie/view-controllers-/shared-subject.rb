module Skylab::DocTest

  module OutputAdapters_::Quickie

    class ViewControllers_::SharedSubject  # #[#026]

      # this one is a little different: near [#024] the subject instance
      # is built off the common paraphernalia IFF it has a line or lines
      # that match a pattern..

      TEMPLATE_FILE___ = '_shared-subject.tmpl'

      def initialize o, cx
        @_common = o
        @_choices = cx
      end

      def to_line_stream

        _s_a = __assemble_body_line_cache

        t = @_choices.load_template_for TEMPLATE_FILE___

        t.set_simple_template_variable @_VAL.matchdata[ :lvar ], :lvar

        t.set_multiline_template_variable(
          Common_::Stream.via_nonsparse_array( _s_a ),
          :code_block_body_lines,
        )

        t.flush_to_line_stream
      end

      def __assemble_body_line_cache

        # as a goofy experiment, what we render takes on one of two forms
        # based on whether the final lvar assignment happens as the last
        # line of the code run..

        __prepare
        __render_the_zero_or_more_lines_that_come_before_the_assignment_line

        # is there a contented line or lines after the assignment line?

        __cache_up_blank_lines  # rendering these depends on whether they trail

        lo = remove_instance_variable :@_first_nonblank_line_object
        if lo
          __finish_the_lines_when_there_are_more_lines lo
        else
          __finish_the_lines_when_the_assignment_line_is_the_last_line
        end

        remove_instance_variable :@_assignment_line_object
        remove_instance_variable :@_line_object_stream
        remove_instance_variable :@_body_line_cache  # result
      end

      def __finish_the_lines_when_there_are_more_lines lo

        # when there are lines after the assignment line (visualize this)
        # pass everything through as is, but add a final line that is just
        # the lvar of interest so that the object of interest is the result
        # of the method call EEK!

        a = remove_instance_variable :@_blank_line_objects
        if a
          a.each( & method( :_accept_line_object ) )
        end

        _accept_line_object @_assignment_line_object
        begin
          _accept_line_object lo
          lo = @_line_object_stream.gets
        end while lo

        _line "#{ @_VAL.matchdata[ :lvar ] }#{ __LTS }"  # EEK
      end

      def __finish_the_lines_when_the_assignment_line_is_the_last_line

        # when the assignment line is the last line, get the lvar and
        # equals sign out of there. whatever remains will be the result
        # of the method call EEK!

        remove_instance_variable :@_blank_line_objects
        # don't render any blank lines that trailed the whole block

        _line @_VAL.matchdata.post_match
      end

      def __render_the_zero_or_more_lines_that_come_before_the_assignment_line

        # the zero or more lines that occur before the last assignment line,
        # pass those through as-is:

        @_VAL.line_offset.times do
          _accept_line_object @_line_object_stream.gets
        end

        @_assignment_line_object = @_line_object_stream.gets  # guaranteed to exist
      end

      def __cache_up_blank_lines
        a = nil
        begin
          lo = @_line_object_stream.gets
          lo || break
          if lo.is_blank_line
            ( a ||= [] ).push lo
            redo
          end
          break
        end while nil

        @_blank_line_objects = a
        @_first_nonblank_line_object = lo
      end

      def _accept_line_object lo
        _line lo.get_content_line
      end

      def _line s
        @_body_line_cache.push s
      end

      def __LTS
        @_assignment_line_object.string[ @_assignment_line_object.LTS_range ]
      end

      def __prepare

        @_body_line_cache = []  # this is the final line string cache

        @_line_object_stream = @_common.to_code_run_line_object_stream

        _val_a = @_common.last_line_index___.variable_assignment_lines
        @_VAL = _val_a.fetch( -1 )  # we just disregard the non-last ones.
      end
    end
  end
end