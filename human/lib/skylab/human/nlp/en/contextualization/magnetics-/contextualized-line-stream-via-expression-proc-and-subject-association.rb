module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Contextualized_Line_Stream_via_Expression_Proc_and_Subject_Association  # ..

      # (.. and selection stack)

      class << self

        def via_magnetic_parameter_store parameter_store
          new.__init_via_parameter_strore( parameter_store ).execute
        end

        def begin_for ps
          new.__init_for_assignment ps
        end

        private :new
      end  # >>

        # #history: the algorithm assimilated from [ac]'s last c15n

      def __init_via_parameter_strore ps
        @emission_proc = ps.emission_proc
        @expression_agent = ps.expression_agent
        @selection_stack = ps.selection_stack
        @to_contextualize_first_line_with_selection_stack = nil
        @to_say_selection_stack_item = ps.to_say_selection_stack_item
        @_ps = ps
        self
      end

      def __init_for_assignment ps
        @_ps = ps
        self
      end

      attr_writer(
        :emission_proc,
        :expression_agent,
        :to_contextualize_first_line_with_selection_stack,
      )

      # --

      def execute

        o = Home_::Sexp::Expression_Sessions::List_through_Eventing::Simple.begin

        o.on_first = method :__map_first_line

        o.on_subsequent = IDENTITY_

        o.to_stream_around __flush_raw_lines_to_stream
      end

      def __map_first_line line

        o = Magnetics_::Contextualized_Line_via_Line_and_Emission.begin
        o.line = line
        o.to_pre_articulate_ = method :___pre_articulate_first_line
        o.execute
      end

      def ___pre_articulate_first_line lc   # lc = "line contextualization"

        __maybe_express_subject_association_as_prefix lc
        __maybe_express_selection_stack_as_suffix lc
        NIL_
      end

      def __maybe_express_subject_association_as_prefix lc

        s = Magnetics_::String_via_Subject_Association.via_magnetic_parameter_store @_ps

        lc.mutate_line_parts_by do |mlp|
          if s
            mlp.prefix = "#{ s }#{ SPACE_ }"  # ..
          end
        end

        NIL_
      end

      def __maybe_express_selection_stack_as_suffix lc

        p = @to_contextualize_first_line_with_selection_stack
        if p
          p[ lc ]
        else
          __express_selection_stack_as_suffix lc
        end

        NIL_
      end

      def __express_selection_stack_as_suffix lc

        o = Here_::Magnetics_::String_Array_via_Selection_Stack_and_Procs.begin
        o.expression_agent = @expression_agent
        o.selection_stack = @selection_stack

        _p = @to_say_selection_stack_item
        _p ||= Express_selection_stack_item___
        o.to_say_other = _p

        s_a = o.execute  # => [ .. "in sub-thing", "in root thing" ]

        _ = if s_a.length.nonzero?
          "#{ SPACE_ }#{ s_a.join SPACE_ }"  # ..
        end

        lc.mutate_line_parts_by do |mlp|
          mlp.suffix = _
        end

        NIL_
      end

      def __flush_raw_lines_to_stream

        lines = []

        _y = ::Enumerator::Yielder.new do |s|
          lines << Plus_newline_if_necessary_[ s ]
        end

        @expression_agent.calculate _y, & @emission_proc

        Common_::Stream.via_nonsparse_array lines
      end

      Express_selection_stack_item___ = -> xx do
        self._K
      end

      This_ = self
    end
  end
end
