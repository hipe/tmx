module Skylab::Brazen

  module Event_Support_  # [#cm-008]#Scope-stack-trick

    Events_::Component_Already_Added = Callback_::Event.prototype_with(  # :+[#035]:C

      :component_already_added,

      :component, nil,
      :component_association, nil,
      :ACS, nil,

      :error_category, :key_error,
      :ok, false,

    ) do | y, ev |

      o = ev.dup
      o.extend Events_::Component_Already_Added::Expresser___
      o.__express_into_under y, self
    end

    module Events_::Component_Already_Added::Expresser___

      include Expresser

      def __express_into_under y, expag

        initialize_as_expresser expag
        index_for_expression_oldschool

        # the way the `@ok` member sees expression is interesting, and has
        # to do with how we express what is expected alongside an expression
        # of current state.
        #
        # if we expected something not to be there already in the "slot"
        # (as is the case with a canonical "add" operation), then we
        # emphasize this by alluding to the past: "already" indicates that
        # the thing is true now and was also true in the past, and
        # furthermore that we expected it not to be so in the past.
        #
        # conversely when 'OK' is trueish, the use of "already" makes it
        # sound uncecessarily accusatory. however, if we say simply
        # "<collection> has <component>", it is ambiguous what it is saying
        # about state change: do we have it now and we didn't before?
        #
        # to say "found existing <component>" it makes it unabiguous that
        # this is not a state change. and it sounds neutral as opposed to
        # unexpected.

        if instance_variable_defined? :@ok
          ok = @ok
        else
          # ??? - we assume false-ish only by virtue of the event class name
        end

        if ok

          accept_sentence_part 'found existing'
          _express_component_somehow

        elsif @can_express_collection_related_

          express_collection_via_members
          accept_sentence_part 'already has'  # :+[#035]:WISH-A
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

        flush_into y
      end

      def _express_component_somehow
        express_component_via_members or accept_sentence_part 'component'
      end
    end
  end
end
