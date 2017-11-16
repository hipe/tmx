module Skylab::Basic

  module Number

    class Normalization

        class << self

          def instance
            @inst ||= new
          end

          def via_arglist a, & x_p  # #[#ca-063] used to have this, may again..
            # (hi.)
            via_iambic a, & x_p
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

        def initialize & p

          if p
            -1 == p.arity or self._MODERNIZE_ME  # #todo
            @listener = p
          end

          @qualified_knownness = nil
          @_do_recognize_positive_sign = false
          @knownness = nil
          @minimum = nil
        end

        def as_attributes_actor_normalize
          _normalize_self
          if ! ( @qualified_knownness || @knownness )
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

              _x = in_st.head_as_is

              _kn = Common_::KnownKnown[ in_st.head_as_is ]

              vw = normalize_knownness _kn do | * i_a, & ev_p |

                self._HAVE_FUN
              end
              if vw
                in_st.advance_one
                Home_.lib_.parse_lib::OutputNode.for vw.value
              else
                vw
              end
            end
          end
        end

        def normalize_qualified_knownness qkn, & p
          otr = dup
          otr._init_copy_with :qualified_knownness, qkn, & p
          otr.execute
        end

        def normalize_knownness kn, & p
          otr = dup
          otr._init_copy_with :knownness, kn, & p
          otr.execute
        end

        def _init_copy_with * x_a, & p
          p and @listener = p
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
            @x = @qualified_knownness.value
          else
            @_is_qualified = false
            @x = @knownness.value
          end

          ok = send :"__when_set_is__#{ @number_set }__"

          if ok and @minimum
            ok = __via_number_and_minimum_validate
          end

          if ok
            Common_::KnownKnown[ @number ]
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

          UNABLE_  # result from above is unreliable
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

          UNABLE_
        end

        def _assoc
          if @_is_qualified
            @qualified_knownness.association
          end
        end

        def _new_invalid_event
          Here_::Uninterpretable.new  # example of #expermiental #[#co-070.1] plain old `new` constructs malleable event
        end

      # ==
      # ==
    end
  end
end
