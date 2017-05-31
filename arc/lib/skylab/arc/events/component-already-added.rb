module Skylab::Autonomous_Component_System

  module Event_Support_  # #[#sl-155] scope stack trick

    Events::ComponentAlreadyAdded = Common_::Event.prototype_with(  # :[#007.C]

      :component_already_added,

      :component, nil,
      :component_association, nil,
      :ACS, nil,

      :expectation_matrix, nil,

      :error_category, :key_error,
      :ok, false,

    ) do | y, ev |

      o = ev.dup
      o.extend Events::ComponentAlreadyAdded::Expresser___
      o.__express_into_under y, self
    end

    module Events::ComponentAlreadyAdded::Expresser___

      include ExpressionMethods

      def __express_into_under y, expag

        initialize_as_expresser expag
        index_for_expression_oldschool

        # the name of the subject "component already added" is a bit
        # misleading: the "surface phenomenon" (in this case adverb)
        # "already" is utilized in the subject's expression conditionally
        # based on the parameters.
        #
        # to say "added the thing *already*" implies that the expectation
        # was "no component, then component" but the reality was "component,
        # then (still) component."
        #
        # in fact we also use the subject for uninflected, informational
        # statements in the positive, also; which would be [expected:
        # "no then yes", actual: "no then yes"].
        #
        # if it is the case that we are using the subject for a confirmation,
        # (which is to say that reality matches expectation) then to include
        # "already" makes it sound
        # sound uncecessarily accusatory. however, if we say simply
        # "<collection> has <component>", it is ambiguous what it is saying
        # about state change: do we have it now and we didn't before?
        #
        # to say "found existing <component>" it makes it unabiguous that
        # this is not a state change. and it sounds neutral as opposed to
        # unexpected.
        #
        # the above ideas expanded into [#hu-066] at #history-A, which has
        # a much more in-depth analysis of what could possibly be done with
        # a four-element boolean tuple like we use here..

        a = @expectation_matrix
        a || self._COVER_ME__meh__

        expectation_then_yes, expectation_now_yes,
          reality_then_yes, reality_now_yes = a

        # we supply a code skeleton for all 16 permutations as an exercise
        # and also as perhaps a template for elsewhere; but most of these
        # permutations should never arrive here.

        if expectation_then_yes
          if expectation_now_yes
            if reality_then_yes
              if reality_now_yes
                __express_declarative_statement_of_positive_static_story_as_expected  # (1)
              else
                _no a  # (2)
              end
            elsif reality_now_yes
              _no a  # (3)
            else
              _no a  # (4)
            end
          elsif reality_then_yes
            if reality_now_yes
              _no a  # (5)
            else
              _no a  # (6)
            end
          elsif reality_now_yes
            _no  # (7)
          else
            _no  # (8)
          end
        elsif expectation_now_yes
          if reality_then_yes
            if reality_now_yes
              __expected_add_has_static_positive  # (9)
            else
              _no a  # (10)
            end
          elsif reality_now_yes
            _no a  # (11)
          else
            _no a  # (12)
          end
        elsif reality_then_yes
          if reality_now_yes
            _no a  # (13)
          else
            _no a  # (14)
          end
        elsif reality_now_yes
          _no a  # (15)
        else
          _no a  # (16)
        end

        flush_into y
      end

      def __expected_add_has_static_positive

        if @can_express_collection_related_

          express_collection_via_members
          accept_sentence_part 'already has'  # #wish #[#007.G]
          _express_component_somehow

        else

          sp = new_subphrase
          sp.express_unique(
            @component_model_string_,
            @component_association_string_,
            @component_string_,
          )
          a = sp.flush_to_array

          if a.length <= 1
            _express_component_somehow
            accept_sentence_part "already existed"
          else
            accept_sentence_part a.shift
            accept_sentence_part "already existed:"
            express_via_nonsparse_array a
          end
        end

        NIL
      end

      def _no a
        fail "DO ME: #{ a.inspect }"
      end

      def __express_declarative_statement_of_positive_static_story_as_expected  # [tm], [sn]
        accept_sentence_part 'found existing'
        _express_component_somehow
        NIL
      end

      def _express_component_somehow
        express_component_via_members or accept_sentence_part 'component'
      end
    end
  end
end
# :#history-A: the comment that led to an article about expression theory
