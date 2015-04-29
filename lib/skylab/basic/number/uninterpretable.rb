module Skylab::Basic

  module Number

    Uninterpretable = Callback_::Event.prototype_with(
        :___terminal_channel_is_in_an_ivar___,  # sanity
        :x, nil,
        :prop, nil,
        :number_set, nil,
        :error_category, :argument_error,
        :ok, false ) do | y, o |

      o.express_all_units_into_under y, self
    end

    class Uninterpretable

      class << self
        public :new
      end  # >>

      def initialize & edit_p

        @minimum = nil
        @_do_report_as_general_failure = false
        @terminal_channel_i = :uninterpretable_under_number_set

        if block_given?
          instance_exec( & edit_p )
        end
      end

      attr_reader :minimum, :terminal_channel_i

      def did_not_match x, prp, min_d=nil, sym

        if min_d
          number_too_small x, prp, min_d, sym
        else
          not_in_number_set x, prp, sym
        end
      end

      def number_too_small x_number, prp, min_number, set_sym=nil

        have :x, x_number,
          :prop, prp,
          :minimum, min_number,
          :number_set, set_sym
      end

      def not_in_number_set x, prp, sym

        have :x, x,
          :prop, prp,
          :number_set, sym
      end

    private

      def general_failure=

        @_do_report_as_general_failure = true
        @terminal_channel_i = :uninterpretable_under_number_set
        KEEP_PARSING_
      end

      def minimum=

        x = iambic_property
        if x
          @minimum = x
          @terminal_channel_i = :number_too_small
        end
        KEEP_PARSING_
      end

      def property_name_symbol=

        sym = iambic_property
        if sym
          @prop = Minimal_Property.via_variegated_symbol sym
          KEEP_PARSING_
        end
      end

    public

      def express_all_units_into_under y, expag

        if @minimum
          if @minimum.zero?
            __express_non_neg y, expag
          else
            __express_minimum y, expag
          end
        else
          __express_set y, expag
        end
      end

      def __express_non_neg y, expag
        o = self
        expag.calculate do

          s = o._ns
          _ = if s
            "a non-negative#{ s }"
          else
            "non-negative"
          end
          y << "#{ par o.prop } must be #{ _ }, had #{ ick o.x }"
        end
      end

      def __express_minimum y, expag
        o = self
        expag.calculate do

          y << "#{ par o.prop || 'number' } must be#{ o._ns }#{
           } greater than or equal to #{
            }#{ val o.minimum }, had #{ ick o.x }"
        end
      end

      def __express_set y, expag

        o = self
        lemma = ( @number_set || :number ).id2name

        expag.calculate do

          y << "#{ par o.prop } must be#{
           } #{ indefinite_noun lemma }, had #{ ick o.x }"
        end
      end

      def _ns

        sym = @number_set
        if sym
          " #{ sym }"
        end
      end
    end
  end
end
