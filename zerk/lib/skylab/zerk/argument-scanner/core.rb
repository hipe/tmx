module Skylab::Zerk

  module ArgumentScanner  # [#052]

    class CommonImplementation

      def parse_primary_value_as_one_such_number_via_mutable_array mutable_a

        sym = @current_primary_symbol
        advance_one
        x = parse_primary_value :must_be_trueish
        if x

          _qkn = Common_::Qualified_Knownness.via_value_and_association x, sym

          mutable_a.push :qualified_knownness, _qkn

          _n11n = Home_.lib_.basic::Number.normalization.new_via_iambic(
            mutable_a, & @listener )

          _kn = _n11n.execute
          _kn  # #todo
        end
      end

      def match_primary_route_value_against h
        route = match_primary_route_against h
        if route
          route.value
        else
          route
        end
      end

      def match_primary_route_against h
        route = match_primary_route_against_ h
        if route && ! route.is_the_no_op_route
          @current_primary_symbol = route.primary_normal_symbol
        end
        route
      end

      def head_as_primary_symbol
        k = head_as_well_formed_potential_primary_symbol_
        @current_primary_symbol = k
        k
      end

      def parse_primary_value * x_a
        parse_primary_value_via_parse_request parse_parse_request x_a
      end

      def parse_parse_request x_a
        Here_::Magnetics::ParseRequest_via_Array[ x_a ]
      end

      def parse_primary_value_via_parse_request req
        Here_::Magnetics::PrimaryValue_via_ParseRequest[ self, req ]
      end

      def when_missing_requireds * x_a
        Here_::When::MissingRequireds.new( x_a, self ).execute
      end

      attr_reader(
        :current_primary_symbol,
      )
    end

    # ==

    Known_unknown_via_reason_symbol = -> sym do

      Common_::Known_Unknown.via_reasoning Reasoning.new sym
    end

    # ==

    class Reasoning

      def initialize sym=nil, & p
        @behavior_by = p
        @reason_symbol = sym
      end

      attr_reader(
        :behavior_by,
        :reason_symbol,
      )
    end

    # ==

    Route = ::Class.new

    class PrimaryHashValueBasedRoute < Route

      def route_category_symbol
        :route_that_is_primary_hash_value_based
      end

      def is_more_backey_than_frontey
        true
      end
    end

    class Route

      def initialize x, k
        @primary_normal_symbol = k
        @value = x
      end

      attr_reader(
        :primary_normal_symbol,
        :value,
      )

      def is_the_no_op_route
        false
      end
    end

    # ==

    Here_ = self
  end
end
# #history: abstracted from common *implementations* between first two
