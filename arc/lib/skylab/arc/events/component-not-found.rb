module Skylab::Arc

  module Event_Support_  # #[#sl-155] #Scope stack trick

    Events::ComponentNotFound = Common_::Event.prototype_with(

      :component_not_found,

      :component, nil,
      :component_association, nil,
      :ACS, nil,

      :error_category, :key_error,
      :ok, false,

    ) do | y, o |

      Events::ComponentNotFound::Express_into_under_of___[ y, self, o ]
    end

    module Events::ComponentNotFound::Express_into_under_of___

      include ExpressionMethods  # (see comments here)

      def self.[] y, expag, o
        o.dup.extend( self ).__express_into_under y, expag
      end

      def __express_into_under y, expag

        # all of the below are abstracted from real-word usage expression
        # structures. even with just the condition tree being the four
        # permutation of two conditionals, the cleanup of a jumble like this
        # is the purpose of [#hu-039] (rule-table-like), investigation of
        # which we are prerequisiting on the completion of [#007] at
        # least.

        # remember that by design any client can implement its own
        # expression of events. all of this is just the default expression
        # strategy.

        @_y = y
        initialize_as_expresser expag
        index_for_expression_oldschool

        if @can_express_collection_related_

          if @collection_string_looks_like_filename_

             __there_is_no_M_with_A_C_in_S

          elsif @can_express_component_related_

            if @can_express_component_

              __S_does_not_have_A_C
            else
              __in_S_there_are_no_M
            end
          else
            self._DECIDE_ME_collection_related_but_no_component_related
          end
        elsif @can_express_component_related_  # but not collection related

          __A_not_found__C
        else
          self._DECIDE_ME_neither
        end
      end

      def __in_S_there_are_no_M

        accept_sentence_part 'in'

        _did = express_unique @collection_model_string_, @collection_string_

        if ! _did
          accept_sentence_part 'component collection'
        end

        component_noun_s = @component_model_string_ || 'such component'

        express_by do
          "there are no #{ plural_noun component_noun_s }"
        end

        _flush
      end

      def __S_does_not_have_A_C  # assume @can_express_collection_related_

        # "<acs> does not have <asc> <cmp>"

        express_any @collection_model_string_

        express_any @collection_string_

        accept_sentence_part 'does not have'

        if @can_express_component_related_

          express_any @component_association_string_

          express_any style_as_ick_if_necessary @component_string_

        else
          accept_sentence_part 'such a component'
        end

        _flush
      end

      def __there_is_no_M_with_A_C_in_S  # assume ONLY @_ACS_s

        # "there is no <mdl> with <asc> "<cmp>" in <ACS>"
        # e.g "three is no no with identifer '[#10]' in foo/bar" (covered)

        accept_sentence_part 'there is no'

        d = list_length

        did_model = express_any @component_model_string_

        asc_s = @component_association_string_
        if asc_s
          if did_model
            accept_sentence_part 'with'
          end
          did_asc = accept_sentence_part asc_s
        end

        s = @component_string_
        if s
          if did_model || did_asc
            s = style_as_ick_if_necessary s
          end
          accept_sentence_part s
        end

        if d == list_length
          accept_sentence_part 'such component'
        end

        # any ACS brings us the prepositional phrase

        sp = new_subphrase
        sp.express_any @collection_model_string_
        sp.express_any @collection_string_
        if sp.list_length.nonzero?
          accept_sentence_part 'in'
          sp.flush_into_list list
        end

        _flush
      end

      def __A_not_found__C

        init_expresser_list

        accept_sentence_part @component_model_string_

        accept_sentence_part 'not found -'

        accept_sentence_part style_as_ick_if_necessary @component_string_

        _flush
      end

      def _flush
        flush_into @_y
      end
    end
  end
end
