module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Contextualized_Line_Stream_via_Precontextualized_Line_Stream_and_Selection_Stack

      class << self

        def via_magnetic_parameter_store ps
          new( ps ).execute
        end

        alias_method :[], :via_magnetic_parameter_store

        private :new
      end  # >>

        # #history: the algorithm assimilated from [ac]'s last c15n

      def initialize ps
        @_ps = ps
      end

      # --

      def execute

        _st = @_ps.precontextualized_line_stream

        _ = Magnetics_::
          Contextualized_Line_Stream_via_First_Line_Proc_and_Precontextualized_Line_Stream[
            method( :__pre_articulate_first_line ), _st ]

        _  # #todo
      end

      def __pre_articulate_first_line lc  # line contextualization

        __maybe_express_subject_association_as_prefix lc
        __maybe_express_selection_stack_as_suffix lc
        NIL_
      end

      def __maybe_express_subject_association_as_prefix lc

        s = Magnetics_::Subject_Association_String_via_Subject_Association_SMALL[ @_ps ]

        lc.mutate_line_parts_by do |mlp|  # #spot-5
          if s
            mlp.prefixed_string = "#{ s }#{ SPACE_ }"  # ..
          end
        end

        NIL_
      end

      def __maybe_express_selection_stack_as_suffix lc

        _p = @_ps.to_contextualize_first_line_with_selection_stack
        _p ||= Contextualize_first_with_selection_stack___[ @_ps ]
        _p[ lc ]
        NIL_
      end

      # ==

    Contextualize_first_with_selection_stack___ = -> ps do

      -> lc do

        if ! ps.to_say_selection_stack_item
          ps.to_say_selection_stack_item = Express_selection_stack_item___
        end

        s_a = Magnetics_::String_Array_via_Procs_and_Selection_Stack[ ps ]

          # => [ .. "in sub-thing", "in root thing" ]

        _ = if s_a.length.nonzero?
          "#{ SPACE_ }#{ s_a.join SPACE_ }"  # ..
        end

        lc.mutate_line_parts_by do |mlp|  # #spot-5
          mlp.suffixed_string = _
        end

        NIL_
      end
    end

      Express_selection_stack_item___ = -> xx do
        self._K
      end
    end
  end
end
