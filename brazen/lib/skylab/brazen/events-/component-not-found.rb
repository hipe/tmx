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

        @expag_ = expag

        resolve_association_related_
        __resolve_component_strings  # after above
        __resolve_ACS_strings

        # WONDERHACK: distilled from real world usage; if the collection
        # term looks like it might be a filesystem path, assume it is
        # possibly long and use the construction that puts that string at
        # the end, etc..

        @_y = y
        if @_cmp_s
          if @_ACS_s and @_ACS_s.include? ::File::SEPARATOR

            __there_is_no_M_with_A_C_in_S
          else
            __S_has_no_A_C
          end
        else
          __in_S_there_are_no_M
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
          cmp_s = Ick_if_necessary_of_under[ cmp_s, @expag_ ]
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

      def __there_is_no_M_with_A_C_in_S

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
            cmp_s = Ick_if_necessary_of_under[ cmp_s, @expag_ ]
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
    end
  end
end
