module Skylab::Common

  module Autoloader

    class FuzzyLookup_

      def initialize
        @method_name_when_exactly_one = nil
        @method_name_when_many = nil
        @method_name_when_zero = nil
        @on_exactly_one = nil
        @on_many = nil
        @on_zero = nil
        if block_given?
          yield self
          freeze
        end
      end

      attr_writer(
        :method_name_when_exactly_one,
        :method_name_when_many,
        :method_name_when_zero,
        :on_exactly_one,
        :on_many,
        :on_zero,
      )

      def execute_for mod, nf, client=nil

        if client
          @client = client
        end

        @module = mod
        @name = nf

        # --

        matches = []
        k = @name.as_approximation

        @module.constants.each do |sym|
          if k == Distill_[ sym ]
            matches.push sym
          end
        end

        case matches.length <=> 1
        when 0
          @match = matches.fetch 0
          __when_exactly_one_match
        when -1
          __when_no_matches
        when 1
          @matches = matches
          __when_multiple_matches
        end
      end

      def __when_multiple_matches
        p = @on_many
        if p
          p[ @matches ]
        else
          m = @method_name_when_many
          if m
            @client.send m, @matches
          else
            when_multiple_matches
          end
        end
      end

      def when_multiple_matches
        raise Here_::NameError, Here_::Say_::Ambiguous[ @matches, @name, @module ]
      end

      def __when_no_matches
        p = @on_zero
        if p
          p[]
        else
          m = @method_name_when_zero
          if m
            @client.send m
          else
            when_no_matches
          end
        end
      end

      def when_no_matches
        raise Here_::NameError, Here_::Say_::Zero[ @name, @module ]
      end

      def __when_exactly_one_match
        p = @on_exactly_one
        if p
          p[ @match ]
        else
          m = @method_name_when_exactly_one
          if m
            @client.send m, @match
          else
            when_exactly_one_match
          end
        end
      end

      def when_exactly_one_match
        @module.const_get @match, false
      end
    end
  end
end
# #history: abstracted from both "const missing" and "const reduce"
