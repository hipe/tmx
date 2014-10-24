module Skylab::MetaHell

  module Parse

    class << self

      def alternation
        Parse_::Alternation__
      end

      def fields
        Parse_::Fields__
      end

      def fuzzy_matcher * a
        if a.length.zero?
          Fuzzy_matcher_
        else
          Fuzzy_matcher_[ * a ]
        end
      end

      def hack_label
        Hack_label_
      end

      def series * a
        if a.length.zero?
          self::Series__
        else
          self::Series__.via_arglist a
        end
      end

      def via_ordered_set
        Parse_::Via_Ordered_Set__
      end

      def via_set
        Parse_::Via_Set__
      end
    end

    # fuzzy matcher - partial match anchored to beginning
    # it's a proc that generates other procs
    #
    #     p = Subject_[].fuzzy_matcher 3, 'foobie'
    #
    #     p[ 'f' ] # => nil
    #     p[ 'foo' ]  # => true
    #     p[ 'foob' ]  # => true
    #     p[ 'foobie-doobie' ]  # => nil
    #

    Fuzzy_matcher_ = -> min, moniker do
      min ||= 1
      len = moniker.length
      use_min = len >= min
      -> tok do
        (( tlen = tok.length )) > len and break
        use_min && tlen < min and break
        moniker[ 0, tlen ] == tok
      end
    end

    # hack label
    # like so -
    #
    #     p = Subject_[].hack_label
    #
    #     p[ :@foo_bar_x ]  # => "foo bar"
    #     p[ :some_method ]  # => "some method"

    Hack_label_ = -> ivar_i do
      MetaHell_::Lib_::Old_name_lib[].labelize( ivar_i ).downcase
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
            Fields__::Flag.via_arglist a
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
