module Skylab::Zerk

  module ArgumentScanner  # [#052]

    class CommonImplementation

      def match_head_against_primaries_hash h
        pair = pair_via_match_head_against_primaries_hash h
        if pair
          pair.value_x
        else
          pair
        end
      end

      def pair_via_match_head_against_primaries_hash h
        pair = pair_via_match_head_against_primaries_hash_ h
        if pair
          @current_primary_symbol = pair.name_symbol
          pair
        else
          @current_primary_symbol = pair
          pair
        end
      end

      def head_as_primary_symbol
        k = self.head_as_primary_symbol_
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

    Known_unknown_with_reason = -> sym, & name_proc do

      _reasoning = Reasoning___.new sym, name_proc

      Common_::Known_Unknown.via_reasoning _reasoning
    end

    # ==

    Reasoning___ = ::Struct.new :reason_symbol, :name_proc

    # ==

    Here_ = self
  end
end
# #history: abstracted from common *implementations* between first two
