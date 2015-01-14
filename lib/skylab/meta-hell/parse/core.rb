module Skylab::MetaHell

  module Parse  # read [#011]

    class << self

      def alternation
        Parse_::Alternation__
      end

      def fields
        Parse_::Fields__
      end

      def function_ sym
        Parse_::Functions_.const_get(
          Callback_::Name.via_variegated_symbol( sym ).as_const,
          false )
      end

      def fuzzy_matcher * a
        Parse_::Functions_::Keyword.new_via_arglist( a ).to_matcher
      end

      # hack a human-readable name from an internal name
      #
      #     p = Subject_[].moniker_
      #
      #     p[ :@foo_bar_x ]  # => "foo bar"
      #     p[ :some_method ]  # => "some method"

      def hack_moniker_ * a
        if a.length.zero?
          Hack_moniker__
        else
          Hack_moniker__[ * a ]
        end
      end

      def series * a
        if a.length.zero?
          self::Series__
        else
          self::Series__.call_via_arglist a
        end
      end

      def via_ordered_set
        Parse_::Via_Ordered_Set__
      end

      def via_set
        Parse_::Via_Set__
      end
    end

    Hack_moniker__ = -> for_eg_an_ivar_symbol do
      Callback_::Name.labelize( for_eg_an_ivar_symbol ).downcase
    end

    module Functions_
      Autoloader_[ self ]
    end

    module Input_Streams_
      Autoloader_[ self ]
    end

    module Fields__

      class << self

        def exponent
          Fields__::Exponent
        end

        def flag * a
          if a.length.zero?
            Fields__::Flag
          else
            Fields__::Flag.call_via_arglist a
          end
        end

        def int
          Fields__::Int
        end
      end

      module Int

        class << self

          def scan_token
            Scan_token__
          end
        end

        Scan_token__ = -> tok do
          RX__ =~ tok and tok.to_i
        end

        RX__ = /\A\d+\z/
      end

      Autoloader_[ self ]
    end

    Parse_ = self
  end
end
