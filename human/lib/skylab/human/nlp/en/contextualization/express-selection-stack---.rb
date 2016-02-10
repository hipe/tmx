module Skylab::Human

  class NLP::EN::Contextualization

    class Express_Selection_Stack___

      def initialize kns
        @_knowns = kns
      end

      def classically

        @_knowns.when_(

          [ # when i get this:
            :selection_stack,
          ],

          [ # i can give this:
            :verb_lemma,
            :verb_subject,
            :verb_object,
          ],
        ) do |kns|
          Classically___.new( kns ).execute
        end
        NIL_
      end

      class Classically___  # #todo - joists only

        # NOTE - don't be fooled by the dates on these lines. we had to
        # update them to fit with the new mechanisms but these ideas are
        # ANCIENT and should probably go away (probably a #feature-island)

        def initialize kns
          @_knowns = kns
        end

        def execute

          kns = @_knowns
          @_ss = ___normal_selection_stack

          @len = @_ss.length

          if @len.nonzero?
            @_slug_a = ___build_nonzero_length_slug_array
          end

          _vs = __subject_noun_phrase
          kns.verb_subject = _vs  # whether trueish or not, it is now known

          _vl = __verb_lemma
          kns.verb_lemma = _vl  # ditto

          _on = __object_noun_phrase
          kns.verb_object = _on  # ditto

          NIL_
        end

        def ___normal_selection_stack

          ss = @_knowns.selection_stack
          if ! ss.respond_to? :each_with_index
            self._DO_ME_convert_linked_list_to_array
          end
          ss
        end

        def ___build_nonzero_length_slug_array

          slug_a = []

          slug_via_name = -> nf do
            nf.as_human  # ..
          end

          # per [#ac-031] only the first node might not participate.

          add_slug_for_first_node = -> o do
            if o
              if o.respond_to? :ascii_only?
                _ = o
              elsif o.respond_to? :name
                nf = o.name
                if nf
                  _ = slug_via_name[ nf ]
                end
              end
            end
            slug_a.push _ ; nil
          end

          add_slug_for_non_first_node = -> o do
            if o.respond_to? :ascii_only?
              _ = o
            else
              _ = slug_via_name[ o.name ]
            end
            slug_a.push _ ; nil
          end

          ss = @_ss

          add_slug_for_first_node[ ss.fetch 0 ]

          ( 1 ... @len ).each do |d|
            add_slug_for_non_first_node[ ss.fetch d ]
          end

          slug_a
        end

        def __subject_noun_phrase

          if @len.nonzero?
            s = @_slug_a.fetch 0
            if _has_many_adjectives
              s = "#{ s } #{ @_slug_a[ 1 .. -3 ].reverse.join SPACE_ }"
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
