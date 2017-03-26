module Skylab::Brazen

  # -> 2

      module Actionesque::Input_Adapters::Via_value_box

        # "iambic literals" are easier to read, but sometimes you just want
        # to pass a plain old box of name-value pairs to your action. this
        # adapter jumps thru some hacky hoops to spoof a box as an argument
        # scanner, and with that leverages the existing parsing logic.

        def self.[] act, bx

          Require_fields_lib_[]

          formals = act.formal_properties
          kp = KEEP_PARSING_

          pxy = Value_as_Stream___.new
          act.argument_scanner_ = pxy

          bx.each_pair do | k, x |

            prp = formals[ k ]
            if ! prp
              pxy.accept_current_token_ k
              act.when_after_process_iambic_fully_stream_has_content pxy
              kp = false
              break
            end

            if Field_::Takes_argument[ prp ]

              pxy.accept_current_token_ x
              kp = act._parse_association_ prp

            elsif x

              # the formal is a flag and the actual is true-ish. disregard what
              # the actual value is, in the interest of iambic isomorphism.

              pxy.clear
              kp = act._parse_association_ prp

            else

              # the formal is a flag and the actual is known but false-ish..
              # it's tempting to add the [ nil or false ] to the argument box,
              # but this is in violation of the iambic isomorphism

            end

            kp or break

          end

          act.remove_instance_variable :@_argument_scanner_

          kp
        end

        class Value_as_Stream___  # #tracking #[#fi-019]

          def head_as_is
            @p[]
          end

          def gets_one
            x = @p[]
            @p = nil
            x
          end

          def accept_current_token_ x
            @p = -> do
              x
            end ; nil
          end

          def clear
            @p = nil
          end
        end
      end
      # <-2
end
