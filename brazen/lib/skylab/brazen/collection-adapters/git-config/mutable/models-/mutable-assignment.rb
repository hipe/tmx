module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Models_::MutableAssignment < Common_::SimpleModel

        # ==

        class AssignmentsFacade  # 1x.

          # (façades are explained at [#008.F])

          def initialize a
            @_all_elements_ = a
          end

          # -- write

          def REPLACE_ASSIGNMENTS st, & p  # experiment for [cu]

            This_::Magnetics.const_get :DeleteEntity_via_Entity_and_Collection, false
              # (so we don't have to register the below as a stowaway)

            _ok = This_::Magnetics::ReplaceEntity_via_Entity_and_Collection.call_by do |o|
              o.will_replace_with_these_name_value_pairs st
              o.all_elements = @_all_elements_
              o.listener = p
            end

            _ok  # hi. #todo
          end

          def delete_assignments_via_assignments__ a
            # (counterpart to `delete_sections_via_sections_`)
            This_::Magnetics::DeleteEntity_via_Entity_and_Collection.call_by do |o|
              o.will_delete_these_actual_instances a
              o.all_elements = @_all_elements_
            end
            # result is a (different) array of the deleted items
          end

          # -- read

          def dereference norm_sym
            DereferenceElement_via_NormalName_and_Collection_[ norm_sym, self ]
          end

          def lookup_softly norm_sym
            el = _lookup_softly_no_unwrap_ norm_sym
            el && el.value_as_result_of_dereference_or_lookup_softy_
          end

          def _lookup_softly_no_unwrap_ norm_sym
            LookupElementSoftlyNoUnwrap_via_NormalName_and_RelevantStream_[ norm_sym, _to_stream ]
          end

          def first  # used as #testpoint, used by [cu] to check for emptiness
            _to_stream.gets
          end

          def _to_stream
            Stream_[ @_all_elements_ ].filter_by do |el|
              IS_ASSIGNMENT_.fetch el._category_symbol_
            end
          end
          alias_method :to_stream_of_assignments, :_to_stream
        end

        # ==
        # -
          def initialize
            @_mutex_for_how_to_define = nil
            yield self
            # don't freeze because for now we might unmarshal our values lazily
          end

          def init_for_parse_based_definition__
            _same
          end

          def init_for_direct_definition__
            _same
          end

          def _same
            remove_instance_variable :@_mutex_for_how_to_define
            @_mutex_for_how_to_unmarshal = nil
          end

          def accept_two_spans_and_frozen_line_ n_d, n_w, v_d, v_w, line

            received_name_s = line[ n_d, n_w ]

            @external_normal_name_symbol = received_name_s.gsub( DASH_, UNDERSCORE_ ).intern
              # per our counterpart, captial letters are OK but not dashes

            @internal_normal_name_string = received_name_s.downcase.freeze

            @__name_string_as_received = received_name_s.freeze

            accept_five_ n_d, n_w, v_d, v_w, line
            NIL
          end

          def accept_five_ n_d, n_w, v_d, v_w, line  # [#008.G] BE CAREFUL

            @_offset_of_name_start = n_d
            @_width_of_name = n_w
            @_offset_of_value_start = v_d
            @_width_of_value = v_w

            @_frozen_line = line ; nil
          end

          # -- will unmarshal

          def accept_already_unmarshaled_value_ x
            remove_instance_variable :@_mutex_for_how_to_unmarshal
            _accept_unmarshaled_value x
            NIL
          end

          def _will_use_unmarshal_method_ m
            remove_instance_variable :@_mutex_for_how_to_unmarshal
            @_value = m ; nil
          end

          # - read

          def description_under _  # [tm]

            # for emissions in events. only while our type system has the
            # constraints it has, the below magically "just works" for now:

            "( #{ @__name_string_as_received } : #{ value.inspect } )"
          end

          def write_bytes_into y
            # ..
            y << @_frozen_line
          end

          def to_line_as_atom_

            # (one day maybe an assignment will be able to span multiple
            #  lines but that day is not today)

            @_frozen_line
          end

          def value_as_result_of_dereference_or_lookup_softy_
            value
          end

          def value
            send @_value
          end

          def to_string_math_five_
            [ @_offset_of_name_start, @_width_of_name,
              @_offset_of_value_start, @_width_of_value, @_frozen_line ]
          end

          # -- unmarshalers

          def __unmarshal_integer_

            _d = @_frozen_line[ @_offset_of_value_start, @_width_of_value ].to_i
            _accept_and_result_in_unmarshaled_value _d
          end

          def __unmarshal_TRUE_
            _accept_and_result_in_unmarshaled_value TRUE
          end

          def __unmarshal_FALSE_
            _accept_and_result_in_unmarshaled_value FALSE
          end

          def _accept_and_result_in_unmarshaled_value x
            _accept_unmarshaled_value x
            send @_value
          end

          def _accept_unmarshaled_value x
            @_value = :__value_as_is
            @__value = x
          end

          def __value_as_is
            @__value
          end

          # --

          # ([#028.B explains these names)

          attr_reader(
            :external_normal_name_symbol,
            :internal_normal_name_string,
          )

          # --

          def _category_symbol_
            :_assignment_
          end

          # ~ ( [cu]

          def is_section_or_subsection
            FALSE
          end
          def is_assignment
            TRUE
          end
          def is_blank_line_or_comment_line
            FALSE
          end
          # ~ )

          def _DUPLICATE_DEEPLY_  # this wil #bite you
            self
          end

          def _FREEZE_AS_DOCUMENT_ELEMENT_  # #freeze
            freeze
          end
        # -
      end
    end
  end
end
# #history-A: broke out of central "mutable" node (spiritually) during heavy refactor
