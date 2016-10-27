module Skylab::Zerk

  module API

    class ArgumentScanner < Home_::ArgumentScanner::CommonImplementation

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
          __initialize_normally x_a, l
        end
      end

      def __initialize_normally x_a, l

        @_scn = Common_::Polymorphic_Stream.via_array x_a
        @_current_token = @_scn.method :current_token

        @__knownness_of_head_as_primary = method :__knownness_of_head_as_primary
        @listener = l
        NIL
      end

      def pair_via_match_head_against_primaries_hash_ h

        Home_::ArgumentScanner::Magnetics::FormalPrimary_via.begin(
          @__knownness_of_head_as_primary,
          self,
        ).flush_to_pair_via_primaries_hash h
      end

      def __knownness_of_head_as_primary

        x = @_current_token.call
        if x
          Common_::Known_Known[ x ]
        else
          self._COVER_ME
          Home_::ArgumentScanner::Known_unknown_with_reason.call(
            :_falsish_value_when_token_expected_,
          )
        end
      end

      def head_as_primary_symbol_
        @_current_token.call
      end

      def current_token_as_is
        @_current_token.call
      end

      def advance_one
        @_scn.advance_one
        @no_unparsed_exists = @_scn.no_unparsed_exists
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

      cached :head_as_strange_name do

        x = @_scn.current_token
        if x.respond_to? :id2name
          Common_::Name.via_variegated_symbol x
        else
          Common_::Name.via_slug x  # ..
        end
      end

      def head_as_normal_symbol
        @_scn.current_token
      end

      attr_reader(
        :listener,
        :no_unparsed_exists,
      )
    end
  end
end
# #history: abstracted from [tmx]
