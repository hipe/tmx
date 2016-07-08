module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Contextualized_Line_Stream_via_Expression_Proc_and_Subject_Association  # ..

      # (.. and selection stack)

      class << self

        def via_magnetic_parameter_store ps
          new( ps ).execute
        end

        private :new
      end  # >>

        # #history: the algorithm assimilated from [ac]'s last c15n

      def initialize ps
        @emission_proc = ps.emission_proc
        @expression_agent = ps.expression_agent
        @selection_stack = ps.selection_stack
        @to_say_selection_stack_item = ps.to_say_selection_stack_item
        @_ps = ps
      end

      def execute

        lines = []
        _y = ::Enumerator::Yielder.new do |s|
          lines << Plus_newline_if_necessary_[ s ]
        end

        @expression_agent.calculate _y, & @emission_proc

        o = Home_::Sexp::Expression_Sessions::List_through_Eventing::Simple.begin

        o.on_first = method :___map_first_line

        o.on_subsequent = IDENTITY_

        o.to_stream_around Common_::Stream.via_nonsparse_array lines
      end

      def ___map_first_line line  # #cp

        o = Magnetics_::Contextualized_Line_via_Line_and_Emission.begin
        o.parameter_store = self
        o.event = NOTHING_
        o.line = line
        o.to_pre_articulate_ = method :___pre_articulate
        o.execute
      end

      def ___pre_articulate lc

        o = Here_::Magnetics_::String_Array_via_Selection_Stack_and_Procs.begin

        o.expression_agent = @expression_agent
        o.selection_stack = @selection_stack

        _p = @to_say_selection_stack_item
        _p ||= Express_selection_stack_item___
        o.say_other_by = _p

        s = Magnetics_::String_via_Subject_Association.via_magnetic_parameter_store @_ps

          if s
            lc.prefix_ = "#{ s } "
          end

        s_a = o.execute

          # `s_a` => [ .. "in sub-thing", "in root thing" ]

          if s_a.length.nonzero?
            lc.suffix_ = " #{ s_a.join SPACE_ }"
          end

          NIL_
      end

      Express_selection_stack_item___ = -> xx do
        self._K
      end

      This_ = self
    end
  end
end
