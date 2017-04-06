module Skylab::Brazen

  class CollectionAdapters::GitConfig

    module Mutable

      class Magnetics_::Assignment_via_DirectDefinition < Common_::MagneticBySimpleModel

        # as with our counterpart similarly structured magnetic, even though
        # there is no document to parse here, we could still corrupt the
        # document if we're not careful to validate "direct" definitions.
        # (more at [#008.C])

        attr_writer(
          :listener,
          :mixed_value,
          :variegated_name_symbol,
        )

        def execute
          ok = __validate_assignment_name
          ok &&= __process_value
          ok && __flush_element
        end

        # -- D

        def __flush_element

          # there was some debate over whether it's worth avoiding the
          # construction of this string if we're not sure we're going to
          # need it. the answer is no.

          buff = ""
          # ..
          n_d = buff.length
          s = remove_instance_variable :@__sanitized_surface_name_string
          n_w = s.length
          buff << s
          buff << " = "
          v_d = buff.length
          s = remove_instance_variable :@__marshaled
          v_w = s.length
          buff << s
          buff << NEWLINE_
          buff.freeze

          _x = remove_instance_variable :@mixed_value

          This_::Models_::MutableAssignment.define do |o|
            o.init_for_direct_definition__
            o.accept_two_spans_and_frozen_line_ n_d, n_w, v_d, v_w, buff
            o.accept_already_unmarshaled_value_ _x
          end
        end

        # -- C

        def __process_value

          x = @mixed_value

          if x
            if x.respond_to? :ascii_only?
              __when_string

            elsif true == x
              __when_TRUE

            elsif x.respond_to? :bit_length
              __when_integer

            elsif x.respond_to? :infinite?
              __when_float

            elsif x.respond_to? :id2name
              self._COVER_ME__use_strings_instead_of_symbols__

            else
              self._COVER_ME__non_atomic_objects_not_marshalable_in_such_a_document__
            end
          elsif false == x
            __when_FALSE
          else
            self._DESIGN_ME__we_dont_know_what_to_do_with_nil__  # #open [#040]
          end
        end

        def __when_string
          if 110 < @mixed_value.length
            self._COVER_ME__sanity_check__string_seems_quite_long__
          else
            s = @mixed_value.dup
            Assignment_::Mutate_value_string_for_marshal[ s ]
            _accept_marshaled s
          end
        end

        def __when_float
          _accept_marshaled @mixed_value.to_s  # precision issues but meh for now
        end

        def __when_integer
          _accept_marshaled @mixed_value.to_s
        end

        def __when_FALSE
          _accept_marshaled MARSHALED_FALSE___
        end

        def __when_TRUE
          _accept_marshaled MARSHALED_TRUE___
        end

        def _accept_marshaled s
          @__marshaled = s ; ACHIEVED_
        end

        # -- B

        def __validate_assignment_name
          s = @variegated_name_symbol.id2name
          if RX_ASSIGNMENT_NAME_ANCHORED___ =~ s
            @__sanitized_surface_name_string = s
            ACHIEVED_
          else
            @listener.call :error, :invalid_variable_name do
              __build_event_B s
            end
            UNABLE_
          end
        end

        def __build_event_B s
          _ev = Common_::Event.inline_not_OK_with(
            :invalid_variable_name,
            :invalid_variable_name, s,
            :error_category, :argument_error,
          )
          _ev  # hi. #todo
        end

        # -- A

        # ==

        MARSHALED_FALSE___ = 'false'
        MARSHALED_TRUE___ = 'true'
        RX_ASSIGNMENT_NAME_ANCHORED___ = /\A#{ RX_ASSIGNMENT_NAME_.source }\z/

        # ==
        # ==
      end
    end
  end
end
# #history-A: broke out of central "mutable" node (spiritually) during heavy refactor
