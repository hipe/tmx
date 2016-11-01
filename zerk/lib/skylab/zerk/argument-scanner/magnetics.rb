module Skylab::Zerk

  module ArgumentScanner

    Magnetics = ::Module.new

    class Magnetics::FormalPrimary_via_PrimariesHash

      # this "faciliator" has a strange, session-heavy interface because [#052] #note-1

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize h, as
        @argument_scanner = as
        @primaries_hash = h
      end

      # ~

      def well_formed_potential_primary_symbol_knownness= kn
        if kn.is_known_known
          @is_well_formed = true
          @formal_primary_request = FormalPrimaryRequest___.new(
            kn.value_x, @primaries_hash )
        else
          @is_well_formed = false
          @_terminal_channel_symbol = kn.reasoning.reason_symbol
        end
        kn
      end

      FormalPrimaryRequest___ = ::Struct.new :well_formed_symbol, :primaries_hash

      def whine_about_how_it_is_not_well_formed
        _always_whine_in_the_same_way  # hi.
      end

      attr_reader(
        :formal_primary_request,
        :is_well_formed,
      )

      # ~

      def route_knownness= kn
        if kn.is_known_known
          @route_was_found = true
          @__user_route = kn.value_x
        else
          @route_was_found = false
          @_terminal_channel_symbol = kn.reasoning.reason_symbol
        end
        kn
      end

      def whine_about_how_route_was_not_found
        _always_whine_in_the_same_way  # hi.
      end

      attr_reader :route_was_found

      # ~

      def to_common_pair_about_route_that_was_found
        Common_::Pair.via_value_and_name(
          @__user_route, @formal_primary_request.well_formed_symbol )
      end

      # --

      def _always_whine_in_the_same_way

        o = Here_::When::UnknownPrimary.begin

        o.strange_primary_value_by = @argument_scanner.method :head_as_is

        if @primaries_hash
          _p = @argument_scanner.method :available_primary_name_stream_via_hash
          o.available_primary_name_stream_by = -> do
            _p[ @primaries_hash ]
          end
        else
          NOTHING_  # #feature-island #scn-coverpoint-2
        end

        o.terminal_channel_symbol = @_terminal_channel_symbol

        o.listener = @argument_scanner.listener

        o.execute
      end
    end

    class Magnetics::PrimaryValue_via_ParseRequest < Common_::Actor::Dyadic

      def initialize as, req
        @argument_scanner = as
        @must_be_trueish = req.must_be_trueish
        @use_method = req.use_method
      end

      def execute
        if @argument_scanner.no_unparsed_exists
          __when_argument_value_not_provided
        else
          __when_argument_is_provided
        end
      end

      def __when_argument_value_not_provided

        Here_::When::Argument_value_not_provided.call(
          @argument_scanner, @argument_scanner.listener )
      end

      def __when_argument_is_provided

        m = @use_method

        x = if m
          @argument_scanner.send m
        else
          @argument_scanner.head_as_is
        end

        if @must_be_trueish
          if x
            @argument_scanner.advance_one  # #here
            x
          else
            __when_supposed_to_be_trueish_but_is_not
          end
        else
          @argument_scanner.advance_one  # #here
          Common_::Known_Known[ x ]
        end
      end

      def __when_supposed_to_be_trueish_but_is_not
        _sym = @argument_scanner.current_primary_symbol
        _x = @argument_scanner.head_as_is
        self._COVER_ME_falseish_argument_value_when_expected_trueish
      end
    end

    class Magnetics::ParseRequest_via_Array < Common_::Actor::Monadic

      def initialize x_a
        @option_array = x_a
      end

      def execute
        if __has_options
          __process_options
        end
        freeze
      end

      def __has_options
        x_a = remove_instance_variable :@option_array
        if x_a.length.nonzero?
          @_scn = Common_::Polymorphic_Stream.via_array x_a
          ACHIEVED_
        end
      end

      def __process_options
        begin
          send OPTIONS___.fetch @_scn.current_token
        end until @_scn.no_unparsed_exists
        remove_instance_variable :@_scn
        NIL
      end

      OPTIONS___ = {
        must_be_trueish: :__flag,
        use_method: :__takes_one_argument,
      }

      def __flag
        instance_variable_set :"@#{ @_scn.gets_one }", true
      end

      def __takes_one_argument
        instance_variable_set :"@#{ @_scn.gets_one }", @_scn.gets_one
      end

      attr_reader(
        :must_be_trueish,
        :use_method,
      )
    end
  end
end
