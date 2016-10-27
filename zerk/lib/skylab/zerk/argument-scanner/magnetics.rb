module Skylab::Zerk

  module ArgumentScanner

    Magnetics = ::Module.new

    class Magnetics::FormalPrimary_via

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize p, client
        @client = client
        @primaries_hash = nil
        @proc_for_knownness_of_head_as_primary = p
        @subtraction_hash = nil
      end

      attr_writer(
        :subtraction_hash,
      )

      def flush_to_pair_via_primaries_hash h
        @primaries_hash = h
        if _the_argument_stream_head_is_well_formed
          if __the_argument_stream_head_corresponds_to_a_known_primary
            __result_in_the_appropriate_pair
          else
            __whine_about_how_there_is_no_such_modifier
          end
        else
          _whine_about_it_for_its_reason
        end
      end

      def flush_to_primary_symbol
        if _the_argument_stream_head_is_well_formed
          @_well_formed_symbol
        else
          _whine_about_it_for_its_reason
        end
      end

      # ~

      def _the_argument_stream_head_is_well_formed

        kn = @proc_for_knownness_of_head_as_primary.call
        if kn.is_known_known
          @_well_formed_symbol = kn.value_x
          ACHIEVED_
        else
          reasoning = kn.reasoning
          @_terminal_channel_symbol = TCS___.fetch reasoning.reason_symbol
          UNABLE_
        end
      end

      TCS___ = {
        _malformed_surface_representation_:  :unknown_primary_or_operator,
        _subtracted_:  :subtracted_primary_referenced,
      }

      def _whine_about_it_for_its_reason
        _whine  # hi.
      end

      # ~

      def __the_argument_stream_head_corresponds_to_a_known_primary

        x = @primaries_hash[ @_well_formed_symbol ]
        if x
          # (we must not do subtraction here - that must be handled by client)
          @__user_value = x
          ACHIEVED_
        else
          @_terminal_channel_symbol = NIL  # use default
          UNABLE_
        end
      end

      def __whine_about_how_there_is_no_such_modifier
        _whine  # hi.
      end

      # ~

      def _whine

        o = Home_::ArgumentScanner::When::UnknownPrimary.begin

        h = @primaries_hash
        if h
          o.recognizable_normal_symbols_proc = h.method :keys
        end

        o.name_by = @client.method :head_as_strange_name

        o.subtraction_hash = @subtraction_hash  # if any

        o.terminal_channel_symbol = @_terminal_channel_symbol

        o.listener = @client.listener

        o.execute
      end

      def __result_in_the_appropriate_pair
        Common_::Pair.via_value_and_name @__user_value, @_well_formed_symbol
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

        Home_::ArgumentScanner::When::Argument_value_not_provided.call(
          @argument_scanner, @argument_scanner.listener )
      end

      def __when_argument_is_provided

        m = @use_method

        x = if m
          @argument_scanner.send m
        else
          @argument_scanner.current_token_as_is
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
        _x = @argument_scanner.current_token_as_is
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
