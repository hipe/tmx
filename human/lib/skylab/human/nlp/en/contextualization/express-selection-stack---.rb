module Skylab::Human

  class NLP::EN::Contextualization

    class Express_Selection_Stack___

      def initialize kns
        @knowns_ = kns
      end

      def nestedly

        @knowns_.when_(
          [  # when i get:
            :expression_proc,
          ],
          [  # i make:
            :line_downstream,
          ],
        ) do |kns|
          Nestedly___.new( kns ).__solve_line_downstream
        end
        NIL_
      end

      def classically

        @knowns_.when_(
          [  # when i get:
            :selection_stack,
          ],
          [  # i make:
            :verb_lemma,
            :verb_subject,
            :verb_object,
          ],
        ) do |kns|
          Classically___[ kns ]
        end
        NIL_
      end

      class Nestedly___ < Here_::Transition_

        # #history: the algorithm assimilated from [ac]'s last c15n

        class << self
          public :new
        end  # >>

        # assume selection_stack and serveral others..

        def __solve_line_downstream

          kns = @knowns_
          nla = Newline_Adder_.new
          kns.expression_agent.calculate nla.y, & kns.expression_proc

          o = Streamer_.new

          o.on_first = method :___map_first_line

          o.on_subsequent = IDENTITY_

          kns.line_downstream = o.to_stream_around nla.to_line_stream

          NIL_
        end

        def ___map_first_line line  # #cp

          lc = Here_::First_Line_Contextualization_.new_ @knowns_
          lc.line = line
          lc.on_pre_articulation_ = method :___pre_articulate
          @_line_c15n = lc
          lc.build_line
        end

        def ___pre_articulate

          lc = @_line_c15n

          o = begin_selection_stack_sayer_
          _p = @knowns_.to_say_selection_stack_item
          _p ||= Express_selection_stack_item___
          o.say_other_by = _p

          _ = Home_.lib_.basic::String

          s = say_subject_association_

          if s
            lc.prefix_ = "#{ s } "
          end

          s_a = o.build_array

          # `s_a` => [ .. "in sub-thing", "in root thing" ]

          if s_a.length.nonzero?
            lc.suffix_ = " #{ s_a.join SPACE_ }"
          end

          NIL_
        end
      end

      Express_selection_stack_item___ = -> xx do
        self._K
      end

      class Classically___ < Here_::Transition_  # #todo - joists only

        # NOTE - don't be fooled by the dates on these lines. we had to
        # update them to fit with the new mechanisms but these ideas are
        # ANCIENT and should probably go away (probably a #feature-island)

        def execute

          slug_a = selection_stack_as_moniker_array__

          @len = slug_a.length
          if @len.nonzero?
            @_slug_a = slug_a
          end

          kns = @knowns_

          _vs = __subject_noun_phrase
          kns.verb_subject = _vs  # whether trueish or not, it is now known

          _vl = __verb_lemma
          kns.verb_lemma = _vl  # ditto

          _on = __object_noun_phrase
          kns.verb_object = _on  # ditto
        end

        def __subject_noun_phrase

          if @len.nonzero?
            s = @_slug_a.fetch 0
            if _has_many_adjectives
              if s
                s = "#{ s } #{ @_slug_a[ 1 .. -3 ].reverse.join SPACE_ }"
              else
                self._COVER_ME
              end
            end
            s
          end
        end

        def __verb_lemma
          if 1 < @len
            @_slug_a.fetch( -1 )
          end
        end

        def __object_noun_phrase
          if 2 < @len
            if _has_many_adjectives
              @_slug_a[ -2 ]
            else
              @_slug_a[ 1 .. -2 ].join SPACE_
            end
          end
        end

        def _has_many_adjectives  # (ridiculous)
          5 < @len
        end
      end
    end
  end
end
