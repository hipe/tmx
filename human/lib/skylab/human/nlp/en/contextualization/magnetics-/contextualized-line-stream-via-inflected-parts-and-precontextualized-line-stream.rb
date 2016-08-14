module Skylab::Human

  class NLP::EN::Contextualization

    # crutch. #todo

    class Magnetics_::Expression_via_Surface_Parts

      class << self

        def via_magnetic_parameter_store ps
          new( ps ).execute
        end
        private :new
      end  # >>

      def initialize ps

        @channel = ps.channel
        @downstream_selective_listener_proc = ps.downstream_selective_listener_proc
        @emission_proc = ps.emission_proc
        @expression_agent = ps.expression_agent
        @subject_association = ps.subject_association
        @surface_parts = ps.surface_parts
        @to_say_subject_association = ps.to_say_subject_association
      end

      def execute

        if :expression == @channel[1] || fail
          __when_expression
        else
          self._NOT_YET_WRITTEN
        end
      end

      def __when_expression

        st = __to_final_line_stream

        @downstream_selective_listener_proc.call( * @channel ) do |y|
          while s = st.gets
            y << s
          end
          y
        end
      end

      def __to_final_line_stream

        o = Magnetics_::
          Contextualized_Line_Stream_via_Expression_Proc_and_Subject_Association.
            begin_for self

        o.emission_proc = @emission_proc
        o.expression_agent = @expression_agent
        o.to_contextualize_first_line_with_selection_stack =
          method :__contextualize_first_line_with_selection_stack
        o.execute
      end

      def __contextualize_first_line_with_selection_stack o

        o.mutate_line_parts_by do |mlp|
          _s = Magnetics_::String_via_Surface_Parts[ @surface_parts ]
          mlp.prefix[0, 0] = "#{ _s }#{ SPACE_ }"  # ..
        end
        NIL_
      end

      attr_reader(
        :expression_agent,
        :subject_association,
        :to_say_subject_association,
      )
    end
  end
end
# #history: born expecting to be crutch
