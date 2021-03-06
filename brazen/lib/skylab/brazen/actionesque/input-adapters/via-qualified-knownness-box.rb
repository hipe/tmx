module Skylab::Brazen
  # -> 2
      module Actionesque::Input_Adapters::Via_qualified_knownness_box

        # PASSIVELY parse-out values from the box, whose each value is a
        # qualified_knownness. do this using any custom parsers and parsing
        # logic that exist to parse argument streams, by spoofing the
        # upstream. unless we add more hacks to this, this can only work
        # for formls whose argument arity is zero or one (separately).

        def self.[] act, bx

          # GET RID OF: argument_scanning_writer_method_name_passive_lookup_proc

          foz = act.formal_properties
          hsm = Hacky_State_Machine___.new

          act.set_argument_scanner__ hsm

          kp = KEEP_PARSING_
          bx.each_pair do | k, qualified_knownness |

            if ! foz.has_key k  # not my formal property - disregard
              next
            end

            if ! qualified_knownness.is_known_known  # formal only, no value - disregard
              next
            end

            prp = qualified_knownness.association
            x = qualified_knownness.value

            if :zero == prp.argument_arity && ! x
              next  # for now we handle flag-like fields whose actual values
            end  # are false-ish by not passing them at all, because for
              # a purely flag-like field this is the only way to do it

            hsm.__replace_value x

            kp = act._parse_association_ prp
            kp or break

          end

          kp
        end

        class Hacky_State_Machine___  # mocky proxy for an argument scanner #[#fi-019]

          def __replace_value x
            @_state = :containing
            @_x = x
            NIL_
          end

          def gets_one
            send :"__gets_one_when__#{ @_state }__"
          end

          def __gets_one_when__containing__
            x = @_x
            @_x = nil
            @_state = :empty
            x
          end
        end
      end
      # <- 2
end
