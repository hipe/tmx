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

      class Nestedly___ < Transition_

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

        def ___map_first_line line

          lc = Here_::First_Line_Contextualization_.new_ @knowns_
          lc.line = line

          lc.on_pre_articulation_ = method :___pre_articulate

          @_line_c15n = lc

          lc.build_line
        end

        def ___pre_articulate

          lc = @_line_c15n
          kns = @knowns_

          _LL = kns.selection_stack_as_linked_list__

          s_a = []
          st = _LL.to_element_stream_assuming_nonsparse
          expag = kns.expression_agent
          p = kns.express_selection_stack_item
          begin
            x = st.gets
            x or break
            s = expag.calculate x, & p
            s or redo
            s_a.push s
            redo
          end while nil

          # `s_a` => [ .. "in sub-thing", "in root thing" ]

          _ = Home_.lib_.basic::String

          s = expag.calculate kns.subject_association, &
            kns.express_subject_association

          if s
            lc.prefix_ = "#{ s } "
          end

          if s_a.length.nonzero?
            lc.suffix_ = " #{ s_a.join SPACE_ }"
          end

          NIL_
        end
      end

      class Classically___ < Transition_  # #todo - joists only

        # NOTE - don't be fooled by the dates on these lines. we had to
        # update them to fit with the new mechanisms but these ideas are
        # ANCIENT and should probably go away (probably a #feature-island)

        def execute

          kns = @knowns_
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

          ss = @knowns_.selection_stack
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
