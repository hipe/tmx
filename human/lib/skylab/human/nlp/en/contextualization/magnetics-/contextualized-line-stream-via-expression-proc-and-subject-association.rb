self._REVISIT

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

          _ = Home_::Sexp::Expression_Sessions::List_through_Eventing::Simple
          o = _.new

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

          o = Here_::Magnetics_::String_Array_via_Selection_Stack_and_Procs.begin
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
    end
  end
end
