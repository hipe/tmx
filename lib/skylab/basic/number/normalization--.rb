module Skylab::Basic

  module Number

    class << self

      def normalization
        Number_::Normalization__
      end
    end  # >>


      class Normalization__

        class << self

          def instance
            @inst ||= new
          end

          def via_arguments x_a
            build_via_iambic x_a  # for now no inline ..
          end
        end

        Callback_::Actor.call self, :properties,
          :argument,
          :number_set,  # symbol
          :minimum

        def initialize
          @minimum = nil
          super
          normalize_self
          freeze
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
            Trio_.new @number, true
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
            bld_did_not_match_event
          end
        end

        include Simple_Selective_Sender_Methods_

        def bld_did_not_match_event

          build_argument_error_event_with :value_not_in_number_set,

              :x, @x, :prop, @argument.property,
              :number_set, @number_set do | y, o |

            y << "#{ par o.prop } must be #{
             }#{ indefinite_noun o.number_set.id2name }, #{
              }had #{ ick o.x }"

          end
        end

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
            bld_number_too_small_event
          end
        end

        def bld_number_too_small_event

          build_argument_error_event_with :number_too_small,

              :number, @number, :minimum, @minimum,
              :prop, @argument.property do | y, o |

            if o.minimum.zero?
              y << "#{ par o.prop } must be non-negative, had #{ ick o.number }"
            else
              y << "#{ par o.prop } must be greater than or equal to #{
               }#{ val o.minimum }, had #{ ick o.number }"
            end
          end
        end
      end

    Number_ = self
  end
end
