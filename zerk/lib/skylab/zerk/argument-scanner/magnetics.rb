module Skylab::Zerk

  module ArgumentScanner

    Magnetics = ::Module.new

    Magnetics::PrimaryNameValue_via_Hash = -> argument_scanner, hash do

      k = argument_scanner.head_as_normal_symbol_for_primary
      if k
        x = hash[ k ]
        if x
          x
        else
          argument_scanner.when_unrecognized_primary(
            hash.method( :keys ), & argument_scanner.listener )
          NIL
        end
      else
        k  # should have emitted (covered)
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
