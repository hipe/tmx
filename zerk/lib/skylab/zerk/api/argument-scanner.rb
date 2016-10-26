module Skylab::Zerk

  module API

    class ArgumentScanner

      # (currently being frontiered by [tmx])

      # so that API and CLI can share some subset of syntax, for custom syntaxes

      class << self
        alias_method :via_array, :new
        undef_method :new
      end  # >>

      def initialize x_a, & l
        if x_a.length.zero?
          @no_unparsed_exists = true
        else
          @listener = l
          @scn = Common_::Polymorphic_Stream.via_array x_a
        end
      end

      def match_head_against_primaries_hash h
        Home_::ArgumentScanner::Magnetics::PrimaryNameValue_via_Hash[ self, h ]
      end

      def parse_primary_value * x_a
        parse_primary_value_via_parse_request parse_parse_request x_a
      end

      def parse_parse_request x_a
        Home_::ArgumentScanner::Magnetics::ParseRequest_via_Array[ x_a ]
      end

      def parse_primary_value_via_parse_request req
        Home_::ArgumentScanner::Magnetics::PrimaryValue_via_ParseRequest[ self, req ]
      end

      def current_token_as_is
        @scn.current_token
      end

      def advance_one
        @scn.advance_one
        @no_unparsed_exists = @scn.no_unparsed_exists
        @_cache_ = nil
      end

      # ((
      DEFINITION_FOR_THE_METHOD_CALLED_CACHED_ = -> m, & p do

        define_method m do
          h = ( @_cache_ ||= {} )
          h.fetch m do
            x = instance_exec( & p )
            h[ m ] = x
            x
          end
        end
      end
      # ))

      define_singleton_method :cached, DEFINITION_FOR_THE_METHOD_CALLED_CACHED_

      cached :head_as_agnostic do

        x = @scn.current_token
        if x.respond_to? :id2name
          Common_::Name.via_variegated_symbol x
        else
          Common_::Name.via_slug x  # ..
        end
      end

      def head_as_normal_symbol_for_primary
        k = @scn.current_token
        @current_primary_symbol = k
        k
      end

      def head_as_normal_symbol
        @scn.current_token
      end

      def when_unrecognized_primary ks_p, & emit
        Home_::ArgumentScanner::When::Unrecognized_primary[ self, ks_p, emit ]
      end

      attr_reader(
        :current_primary_symbol,
        :listener,
        :no_unparsed_exists,
      )
    end
  end
end
# #history: abstracted from [tmx]
