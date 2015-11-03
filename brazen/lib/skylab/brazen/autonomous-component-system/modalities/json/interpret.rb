module Skylab::Brazen

  module Autonomous_Component_System

    module Modalities::JSON

      class Interpret  # (notes in [#083])

        def initialize & p
          @on_event_selectively = p
        end

        attr_writer(
          :ACS,
          :context_string_proc_stack,
          :JSON,
        )

        def execute
          @_parsed_unsanitized_mutable_mixed = Home_.lib_.JSON.parse @JSON
          _common_execute
        end

      protected

        attr_writer(
          :_association,
          :_parsed_unsanitized_mutable_mixed,
        )

        def _resolve_sanitized_value

          ok = _common_execute
          if ok
            @sanitized_value = remove_instance_variable :@ACS
            ok
          else
            ok
          end
        end

        # ~ look like leaf

        def sanitized_value
          @sanitized_value  # warn me
        end

        def association
          @_association
        end

      private

        def _common_execute

          ok = __resolve_mutable_hash
          ok &&= __init_units_of_work
          ok &&= __resolve_sanitized_values
          ok && __accept_sanitized_values
        end

        def __resolve_mutable_hash

          x = remove_instance_variable :@_parsed_unsanitized_mutable_mixed

          if x.respond_to? :each_pair
            @_mutable_hash = x
            ACHIEVED_
          else
            Modalities::JSON::When_[ x, self, :Shape ]
          end
        end

        def __init_units_of_work  # #note-JSON-A about this loop

          uow_a = []

          cmp_oes_p = ACS_::Interpretation::Component_handler[
            @ACS, & @on_event_selectively ]

          h = remove_instance_variable :@_mutable_hash
          ok = true

          st = if @ACS.respond_to? :to_association_stream_for_serialization
            @ACS.to_association_stream_for_serialization
          else
            ACS_::Reflection::To_association_stream[ @ACS ]
          end

          begin
            asc = st.gets
            asc or break

            k = asc.name.as_lowercase_with_underscores_symbol.id2name

            none = false
            x = h.fetch k do
              none = true ; nil
            end
            none and redo  # (we don't nilify these for now)
            h.delete k

            _yes = ACS_::Reflection::Model_is_compound[ asc.component_model ]

            if _yes && x  # process a false-ish compound value as leaf
              uow = __recurse x, asc
              if uow
                uow_a.push uow
              else
                ok = uow
                break
              end
            else
              uow_a.push Leaf___.new( x, asc, @ACS, & cmp_oes_p )
              ok = true
            end

            redo
          end while nil

          if ok && h.length.nonzero?
            ok = Modalities::JSON::When_[ h, self, :Extra ]
          end

          if ok && uow_a.length.zero?
            ok = Modalities::JSON::When_[ self, :Empty ]
          end

          if ok
            @_units_of_work = uow_a
          end

          ok
        end

        def __recurse x, asc

          o = self.class.new( & @on_event_selectively )
          ok = __add_child_component o, asc
          ok &&= __add_the_rest o, x, asc
          ok && o
        end

        def __add_child_component o, asc

          cmp = ACS_::Interpretation::Build_empty_child_bound_to_parent.call(
            asc,
            @ACS,
            & @on_event_selectively )

          if cmp
            o.ACS = cmp
            ACHIEVED_
          else
            self._COVER_ME_failed_to_build_empty_child_component__assumed_correct_as_is
            cmp
          end
        end

        def __add_the_rest o, x, asc

          o._association = asc

          a = @context_string_proc_stack.dup
          a.push -> do
            "in #{ ick asc.name.as_lowercase_with_underscores_symbol.id2name }"
          end

          o.context_string_proc_stack = a

          o._parsed_unsanitized_mutable_mixed = x

          ACHIEVED_
        end

        def __resolve_sanitized_values

          ok = false
          @_units_of_work.each do | uow |
            ok = uow._resolve_sanitized_value
            ok or break
          end
          ok
        end

        def __accept_sanitized_values

          accpt = ACS_::Interpretation::Accepter_for[ @ACS ]

          @_units_of_work.each do | uow |

            accpt[ uow.sanitized_value, uow.association ]
          end
          ACHIEVED_
        end

      public

        attr_reader(
          :context_string_proc_stack,
          :on_event_selectively,
        )

        class Leaf___

          def initialize x, asc, acs, & p

            @_ACS = acs
            @association = asc
            @_my_oes = p
            @_unsanitized_value_x = x
          end

          def _resolve_sanitized_value

            _vp = Value_Popper___.new @_unsanitized_value_x

            vw = ACS_::Interpretation::Build_component_normally[
              _vp, @association, @_ACS, & @_my_oes ]

            if vw
              @sanitized_value = vw.value_x
              ACHIEVED_
            else
              vw
            end
          end

          def sanitized_value
            @sanitized_value
          end

          attr_reader(
            :association,
          )
        end

        class Value_Popper___  # :+[#br-085]

          def initialize x

            @unparsed_exists = true
            @_p = -> do
              @unparsed_exists = false
              remove_instance_variable :@_p
              x
            end
          end

          def no_unparsed_exists
            ! @unparsed_exists
          end

          attr_reader :unparsed_exists

          def gets_one
            @_p[]
          end
        end
      end
    end
  end
end
