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
        @listener = l
        NIL
      end

      def match_primary_route_against_ h

        o = Home_::ArgumentScanner::
            Magnetics::FormalPrimary_via_PrimariesHash.begin h, self

        o.well_formed_potential_primary_symbol_knownness = __well_formed_knownness

        if o.is_well_formed

          o.route_knownness = __route_knownness_via_request o.formal_primary_request

          if o.route_was_found

            o.route
          else
            o.whine_about_how_route_was_not_found
          end
        else
          o.whine_about_how_it_is_not_well_formed
        end
      end

      def __well_formed_knownness
        x = @_current_token.call
        if x.respond_to? :id2name
          Common_::Known_Known[ x ]
        else
          Home_::ArgumentScanner::Known_unknown_via_reason_symbol[ :expected_symbol ]
        end
      end

      def __route_knownness_via_request req
        k = req.well_formed_symbol
        x = req.primaries_hash[ k ]
        if x
          Common_::Known_Known[ Home_::ArgumentScanner::PrimaryHashValueBasedRoute.new x, k ]
        else
          Home_::ArgumentScanner::Known_unknown_via_reason_symbol[ :unknown_primary ]
        end
      end

      def available_primary_name_stream_via_hash h
        Stream_.call h.keys do |sym|
          Common_::Name.via_variegated_symbol sym
        end
      end

      def head_as_well_formed_potential_primary_symbol_
        @_current_token.call
      end

      def advance_one
        @_scn.advance_one
        @no_unparsed_exists = @_scn.no_unparsed_exists
      end

      def head_as_normal_symbol
        @_scn.current_token
      end

      def head_as_is
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
