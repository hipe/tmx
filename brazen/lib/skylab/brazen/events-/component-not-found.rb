module Skylab::Brazen

  module Event_Support_  # :+"that trick"

    Events_::Component_Not_Found = Callback_::Event.prototype_with(

      :component_not_found,

      :component, nil,
      :component_association, nil,
      :ACS, nil,

      :error_category, :key_error,
      :ok, false

    ) do | y, o |

      Events_::Component_Not_Found::Express_into_under_of___[ y, self, o ]
    end

    module Events_::Component_Not_Found::Express_into_under_of___

      include Expresser  # (see comments here)

      def self.[] y, expag, o
        o.dup.extend( self ).__express_into_under y, expag
      end

      def __express_into_under y, expag

        # all of the below are abstracted from real-word usage expression
        # structures. even with just the condition tree being the four
        # permutation of two conditionals, the cleanup of a jumble like this
        # is the purpose of [#hu-039] (rule-table-like), investigation of
        # which we are prerequisiting on the completion of [#br-035] at
        # least.

        # but our condition tree is deeper still: one of the more spurious
        # (while still pragmatic) of our decisions is based on whether the
        # collection expression looks like a path, because filesystem paths
        # are generally "longer" and so they look "better" at the very end
        # of the expression; so we express these as a prepositional phrase
        # as "..in <path>" instead of expressing the path as the referent
        # ("<path> did not have..")!

        # remember that by design any client can implement its own
        # expression of events. all of this is just the default expression
        # strategy.

        @expag_ = expag
        @_y = y

        resolve_association_related_
        __resolve_component_strings  # after above
        __resolve_ACS_strings

        # ~ the would-be rule table inputs

        component = @_cmp_s && true
        component_model = @_component_model_s && true
        component_related = component || component_model

        collection = @_ACS_s && true
        collection_model = @_ACS_model_s && true
        collection_related = collection || collection_model

        if collection
          collection_looks_like_filename = @_ACS_s.include? ::File::SEPARATOR
        end

        # ~ the would-be rule table

        if collection_related

          if collection_looks_like_filename

             __there_is_no_M_with_A_C_in_S

          elsif component_related

            if component

              __S_has_no_A_C
            else
              __in_S_there_are_no_M
            end
          else
            self._DECIDE_ME_collection_related_but_no_component_related
          end
        elsif component_related  # but not collection related

          __A_not_found__C
        else
          self._DECIDE_ME_neither
        end
      end

      def __in_S_there_are_no_M

        component_noun_s = @_component_model_s || 'such component'

        a = []

        s = @_ACS_model_s
        if s
          a.push s
        end

        s = @_ACS_s
        if s
          a.push s
        end

        if a.length.zero?
          a.push 'component collection'
        end

        @_y << ( @expag_.calculate do
          "in #{ a * SPACE_ } there are no #{ plural_noun component_noun_s }"
        end )
      end

      def __resolve_component_strings

        @_cmp_s = determine_component_string_
        @_component_model_s = determine_component_model_string_
        NIL_
      end

      def __resolve_ACS_strings

        @_ACS_s = determine_ACS_string_
        @_ACS_model_s = determine_ACS_model_string_
        NIL_
      end

      def __S_has_no_A_C

        # "<acs> has no <asc> <cmp>"

        cmp_s = @_cmp_s
        asc_s = @asc_s_
        acs_s = @_ACS_s

        a = []
        d = a.length

        s = @_ACS_model_s and a.push s

        acs_s and a.push acs_s
        if d == a.length
          a.push 'there is no'
        else
          needs_article = true
          a.push 'does not have'
        end

        d = a.length
        if asc_s
          a.push asc_s
        end

        if cmp_s
          cmp_s = style_as_ick_if_necessary cmp_s
          a.push cmp_s
        end

        if d == a.length
          if needs_article
            a.push 'such a component'
          else
            a.push 'such component'
          end
        end

        @_y << ( a * SPACE_ )
      end

      def __there_is_no_M_with_A_C_in_S  # assume ONLY @_ACS_s

        # "there is no <mdl> with <asc> "<cmp>" in <ACS>"
        # e.g "three is no no with identifer '[#10]' in foo/bar" (covered)

        a = [ 'there is no' ]
        d = a.length

        asc_s = @asc_s_
        cmp_s = @_cmp_s

        mdl_s = determine_component_model_string_
        if mdl_s
          a.push mdl_s
          if asc_s
            a.push 'with'
          end
        end

        if asc_s
          a.push asc_s
        end

        if cmp_s
          if mdl_s || asc_s
            cmp_s = style_as_ick_if_necessary cmp_s
          end
          a.push cmp_s
        end

        if d == a.length
          a.push 'such component'
        end

        # any ACS brings us the prepositional phrase

        a_ = []
        s = @_ACS_model_s and a_.push s
        s = @_ACS_s
        s and a_.push s
        if a_.length.nonzero?
          a.push 'in'
          a.concat a_
        end

        @_y << ( a * SPACE_ )
      end

      def __A_not_found__C

        init_list_

        _accept @_component_model_s

        _accept 'not found -'

        _accept style_as_ick_if_necessary @_cmp_s

        flush_into @_y
      end
    end
  end
end
