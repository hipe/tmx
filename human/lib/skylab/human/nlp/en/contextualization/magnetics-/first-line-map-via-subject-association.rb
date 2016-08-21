module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::First_Line_Map_via_Subject_Association < Magnet_

        # #history: the algorithm assimilated from [ac]'s last c15n

      # this expression strategy differs widely from others in the pipeline
      # in these ways:
      #
      #   - it does *not* have expression for a trilean at all.
      #
      #   - it does not involve *two* lemmas (a subject and a verb) but
      #     only one (a subject), derived from the subject association.
      #     we assume that the received expression will provide its own
      #     verb (i.e being a "preterite" expression).
      #
      # as such we avoid those parts of the pipeline dealing with the
      # trilean and lemmas entirely. (we tried to work within these paths
      # but it was too painful.)
      #
      # any provided selection stack, then, is (in our default provided
      # expression behavior) expressed straighforwardly as a series of
      # "nested" prepositional phrases ("in foo in bar in baz"), which
      # also differs widely from the paths in the pipeline that apply
      # a more structured semantic interpretation of the selection stack.

      def execute

        __init_express_subject_association
        __init_express_selection_stack
        remove_instance_variable :@ps_

        -> line do

          lc = Magnetics_::Line_Contextualization_via_Line[ line ]

          @__express_subject_association[ lc ]
          @_express_selection_stack[ lc ]

          lc.to_string
        end
      end

      def __init_express_subject_association

        ps = @ps_

        final_s = Magnetics_::Subject_Association_String_via_Subject_Association[ ps ]
        # (no trailing space because #c15n-spot-1)

        @__express_subject_association = -> lc do

          lc.mutable_line_parts.prefixed_string = final_s.dup
            # duped because custom expressions might mutate it, and we're
            # not sure whether or not we must be idempotent, so we assume yes
        end ; nil
      end

      def __init_express_selection_stack

        if @ps_.selection_stack
          p = @ps_.to_contextualize_first_line_with_selection_stack
          if p
            @_express_selection_stack = p
          else
            __do_init_express_selection_stack
          end
        else
          self._COVER_ME
        end
        NIL_
      end

      def __do_init_express_selection_stack

        if ! @ps_.to_say_selection_stack_item
          @ps_.to_say_selection_stack_item = Express_selection_stack_item___
        end

        s_a = Magnetics_::Normal_Selection_Stack_via_Selection_Stack[ @ps_ ]
          # => [ .. "in sub-thing", "in root thing" ]

        _ = if s_a.length.nonzero?
          s_a.join SPACE_  # (no leading space because #c15n-spot-1)
        end

        @__selection_stack_as_postfix = _

        @_express_selection_stack = method :__express_selection_stack_into ; nil
      end

      def __express_selection_stack_into lc
        lc.mutable_line_parts.suffixed_string = @__selection_stack_as_postfix
        NIL_
      end

      # ==

      Express_selection_stack_item___ = -> xx do
        self._K
      end
    end
  end
end
