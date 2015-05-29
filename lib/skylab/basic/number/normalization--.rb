module Skylab::Basic

  module Number

    # ->

      class Normalization__

        class << self

          def instance
            @inst ||= new
          end

          def new_with * a  # :+[#cb-063]
            new_via_arglist a
          end

          def new_via_arglist a  # :+[#cb-063] used to have this, may again
            new do
              process_iambic_fully a
            end
          end

          include Simple_Selective_Sender_Methods_  # ick/meh
        end  # >>

        Callback_::Actor.call self, :properties,
          :argument,
          :number_set,  # symbol
          :minimum

        def initialize
          @argument = nil
          @minimum = nil
          super
          normalize_self
          if ! @argument
            freeze
          end
        end

        def to_parser_proc

          -> in_st, & x_p do

            if in_st.unparsed_exists

              x_p and self._NICE

              _x = in_st.current_token
              _trio = Callback_::Trio.via_value _x

              arg = normalize_argument _trio do | * i_a, & ev_p |

                self._HAVE_FUN
              end

              arg and begin
                in_st.advance_one
                Basic_.lib_.parse_lib::output_node.new arg.value_x
              end
            end
          end
        end

        def normalize_argument arg, & oes_p
          otr = dup
          otr.init_copy_with :argument, arg, & oes_p
          otr.execute
        end

        protected def init_copy_with * x_a, & oes_p
          oes_p and @on_event_selectively = oes_p
          process_iambic_fully x_a
          normalize_self
        end

        private def normalize_self
          @number_set ||= :integer
          nil
        end

        def execute
          @x = @argument.value_x  # might not have been provided. we don't care
          ok = send @number_set
          if ok and @minimum
            ok = via_number_and_minimum_validate
          end
          if ok
            Callback_::Trio.via_value @number
          else
            @result
          end
        end

        def integer  # resolve number when number set is integer
          if @x.respond_to? :bit_length
            @number = @x
            PROCEDE_
          else
            if @x.respond_to? :infinite?
              @x = "#{ @x }"  # hackish but less moving parts
              # if we convert floats to ints in this way
            end
            via_x_resolve_integer_for_number
          end
        end

        def via_x_resolve_integer_for_number
          @md = INTEGER_RX__.match @x
          if @md
            via_matchdata_resolve_integer_for_number
          else
            @result = result_when_did_not_match
            UNABLE_
          end
        end
        INTEGER_RX__ = /\A-?\d+\z/

        def result_when_did_not_match
          maybe_send_event :error, :invalid_property_value do

            _new_invalid_event.did_not_match @x, @argument.property, @number_set
          end
        end

        include Simple_Selective_Sender_Methods_

        def via_matchdata_resolve_integer_for_number
          @number = @md[ 0 ].to_i
          ACHIEVED_
        end

        def via_number_and_minimum_validate
          if @minimum <= @number
            PROCEDE_
          else
            @result = result_when_number_is_too_small
            UNABLE_
          end
        end

        def result_when_number_is_too_small

          maybe_send_event :error, :invalid_property_value do

            _new_invalid_event.number_too_small(
              @number, @argument.property, @minimum )
          end
        end

        def _new_invalid_event
          Number_::Uninterpretable.new
        end
      end

      # <-
  end
end
