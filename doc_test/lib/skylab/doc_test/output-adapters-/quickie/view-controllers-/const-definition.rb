module Skylab::DocTest

  module OutputAdapters_::Quickie

    class ViewControllers_::ConstDefinition  # see [#010]:A

      TEMPLATE_FILE___ = '_const-definition.tmpl'

      class << self
        alias_method :via_two_, :new
        undef_method :new
      end  # >>

      def initialize o, cx

        @_choices = cx
        @_common = o
        @_test_file_context = o.test_file_context_proc__.call

        @__EXPERIMENT_sanity_mutex = nil
      end

      def to_branch_local_document_node_matcher
        Branch_local_document_node_matcher___
      end

      Branch_local_document_node_matcher___ = -> docnode do

        sym = docnode.category_symbol

        if :const_definition == sym

          ACHIEVED_  # per [#038] we assume only one such node per branch

        elsif :before == sym

          _hi = docnode.node_internal_identifying_symbol

          BEFORE_ALL_ == _hi  # same
        end
      end

      def write_identifying_information_into vs

        remove_instance_variable :@__EXPERIMENT_sanity_mutex  # only once, right?
        NOTHING_  # hi.
      end

      def to_mapper__

        @___did ||= __init

        _const = @_common.const_assignment_line_match.matchdata[ :const ]

        rx = /(?=\b#{ _const }\b)/  # assuming the rules about consts

        repl = @_localizing_prefix

        -> body_line_stream do
          body_line_stream.map_by do |line|
            # #to-benchmark :[#ts-015] - is it faster?
            if line.frozen?  # #spot2.1
              line.gsub rx, repl
            else
              line.gsub! rx, repl
              line
            end
          end
        end
      end

      def to_line_stream
        send @__to_line_stream  # sanity - this strange order
      end

      def __to_line_stream_when_prepared

        t = @_choices.load_template_for TEMPLATE_FILE___

        _st = Stream_[ @__localized_line_strings ]

        t.set_multiline_template_variable _st, :modified_const_definition_lines

        t.flush_to_line_stream
      end

      def __init
        __init_localizing_prefix
        __init_localized_line_strings
        @__to_line_stream = :__to_line_stream_when_prepared
        ACHIEVED_
      end

      def __init_localizing_prefix
        _ = @_test_file_context.short_hopefully_unique_stem
        @_localizing_prefix = "X_#{ _ }_"  # is [#010]:C
        NIL
      end

      def __init_localized_line_strings

        # we need random access to the lines of the const definition (even
        # though the line of interest is very likely the first line).

        para = @_common
        lines = para.to_code_run_line_object_stream.to_a  # your own mutable array

        while lines.length.nonzero? && lines.last.is_blank_line
          lines.pop
        end  # (aesthetics, covered)

        lmd = para.const_assignment_line_match
        line_d = lmd.line_offset
        md = lmd.matchdata
        lmd = nil

        line = lines.fetch line_d  # very likely the first line
        mutate_me = line.string.dup
        begin_, end_ = md.offset :const
        _new_const = "#{ @_localizing_prefix }#{ md[ :const ] }"
        mutate_me[ begin_ ... end_ ] = _new_const

        line = line.dup_by do |o|
          o.string = mutate_me
        end

        lines[ line_d ] = line

        @__localized_line_strings = lines.map do |o|
          o.get_content_line
        end
        NIL
      end

      def paraphernalia_category_symbol
        :const_definition
      end
    end
  end
end
