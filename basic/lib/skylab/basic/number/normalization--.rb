module Skylab::Basic

  module Number

    # ->

      class Normalization__

        class << self

          def instance
            @inst ||= new
          end

          def new_with * a, & x_p  # #[#ca-063]
            new_via_iambic a, & x_p
          end

          def new_via_arglist a, & x_p  # #[#ca-063] used to have this, may again..
            # (hi.)
            new_via_iambic a, & x_p
          end

          # include Simple_Selective_Sender_Methods_  # ick/meh

          private :new
        end  # >>

        Attributes_actor_.call( self,
          qualified_knownness: nil,
          knownness: nil,
          number_set: nil,  # symbol
          minimum: nil,
        )

        def initialize & oes_p

          if oes_p
            -1 == oes_p.arity or self._MODERNIZE_ME  # #todo
            @on_event_selectively = oes_p
          end

          @qualified_knownness = nil
          @_do_recognize_positive_sign = false
          @knownness = nil
          @minimum = nil
        end

        def process_iambic_passively st  # #[#fi-022]
          super && normalize
        end

        def normalize
          _normalize_self
          if ! @qualified_knownness
            freeze
          end
          KEEP_PARSING_
        end

      private

        def recognize_positive_sign=

          @_do_recognize_positive_sign = true
          KEEP_PARSING_
        end

      public

        def to_parser_proc

          -> in_st, & x_p do

            if in_st.unparsed_exists

              x_p and self._NICE

              _x = in_st.current_token

              _kn = Callback_::Known_Known[ in_st.current_token ]

              vw = normalize_knownness _kn do | * i_a, & ev_p |

                self._HAVE_FUN
              end
              if vw
                in_st.advance_one
                Home_.lib_.parse_lib::OutputNode.for vw.value_x
              else
                vw
              end
            end
          end
        end

        def normalize_qualified_knownness qkn, & oes_p
          otr = dup
          otr._init_copy_with :qualified_knownness, qkn, & oes_p
          otr.execute
        end

        def normalize_knownness kn, & oes_p
          otr = dup
          otr._init_copy_with :knownness, kn, & oes_p
          otr.execute
        end

        def _init_copy_with * x_a, & oes_p
          oes_p and @on_event_selectively = oes_p
          process_iambic_fully x_a
          _normalize_self
        end

        def _normalize_self
          @number_set ||= :integer
          NIL_
        end

        def execute

          if @qualified_knownness
            @_is_qualified = true
            @x = @qualified_knownness.value_x
          else
            @_is_qualified = false
            @x = @knownness.value_x
          end

          ok = send :"__when_set_is__#{ @number_set }__"

          if ok and @minimum
            ok = __via_number_and_minimum_validate
          end

          if ok
            Callback_::Known_Known[ @number ]
          else
            @result
          end
        end

        def __when_set_is__integer__

          if @x.respond_to? :bit_length
            @number = @x
            PROCEDE_
          else
            if @x.respond_to? :infinite?
              @x = "#{ @x }"  # hackish but less moving parts
              # if we convert floats to ints in this way
            end
            __via_x_resolve_integer_for_number
          end
        end

        def __via_x_resolve_integer_for_number

          @md = INTEGER_RX__.match @x
          if @md
            __via_matchdata_resolve_integer_for_number
          else
            @result = _result_when_did_not_match
            UNABLE_
          end
        end

        INTEGER_RX__ = /\A

          (?<sign>
            (?<plus> \+ ) |
            (?<minus> - )
          )?
          (?<digits> \d + )

        \z/x

        def _result_when_did_not_match

          maybe_send_event :error, :invalid_property_value do

            _new_invalid_event.did_not_match @x, _assoc, @number_set
          end
        end

        include Simple_Selective_Sender_Methods_

        def __via_matchdata_resolve_integer_for_number

          md = @md
          d = md[ :digits ].to_i
          if md[ :sign ]
            if md[ :plus ]
              if @_do_recognize_positive_sign
                @number = d ; ACHIEVED_
              else
                @result = _result_when_did_not_match
                UNABLE_
              end
            else
              d *= -1  # yes `to_i` would have done this too
              @number = d ; ACHIEVED_
            end
          else
            @number = d ; ACHIEVED_
          end
        end

        def __via_number_and_minimum_validate

          if @minimum <= @number
            PROCEDE_
          else
            @result = __result_when_number_is_too_small
            UNABLE_
          end
        end

        def __result_when_number_is_too_small

          maybe_send_event :error, :invalid_property_value do

            _new_invalid_event.number_too_small(
              @number, _assoc, @minimum )
          end
        end

        def _assoc
          if @_is_qualified
            @qualified_knownness.association
          end
        end

        def _new_invalid_event
          Number_::Uninterpretable.new
        end
      end

      # <-
  end
end
