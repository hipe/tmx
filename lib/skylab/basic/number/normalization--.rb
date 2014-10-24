module Skylab::Brazen

  class Model_

    module Entity

      class Normalizers__::Numeric < Model_::Entity::Normalizer_

        class << self
          def instance
            @inst ||= new
          end
        end

        Callback_::Actor[ self, :properties,
          :argument,
          :OK_value_p,
          :event_receiver,
          :number_set,  # symbol
          :minimum ]

        def initialize
          @minimum = nil
          super
          normalize_self
          freeze
        end

        protected def init_copy_with * x_a
          process_iambic_fully x_a
          normalize_self
        end

        private def normalize_self
          @number_set ||= :integer
          super
        end

        def normalize_via_three arg, val_p, evr_x
          otr = dup
          otr.init_copy_with :argument, arg,
            :OK_value_p, val_p,
            :event_receiver, evr_x
          otr.execute
        end

        def execute
          @x = @argument.value_x  # might not have been provided. we don't care
          ok = send @number_set
          if ok and @minimum
            ok = via_number_and_minimum_validate
          end
          if ok
            @OK_value_p[ @number ]
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

          send_not_OK_event_with :value_not_in_number_set,

              :x, @x, :prop, @argument.property,
              :number_set, @number_set, -> y, o do

            y << "#{ par o.prop } must be #{
             }#{ indefinite_noun o.number_set.id2name }, #{
              }had #{ ick o.x }"

          end
        end

        def via_matchdata_resolve_integer_for_number
          @number = @md[ 0 ].to_i
          ACHEIVED_
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

          send_not_OK_event_with :number_too_small,

              :number, @number, :minimum, @minimum,
              :prop, @argument.property, -> y, o do

            if o.minimum.zero?
              y << "#{ par o.prop } must be non-negative, had #{ ick o.number }"
            else
              y << "#{ par o.prop } must be greater than or equal to #{
               }#{ val o.minimum }, had #{ ick o.number }"
            end
          end
        end
      end
    end
  end
end
