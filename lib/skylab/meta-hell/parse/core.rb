module Skylab::MetaHell

  module Parse

    def self.alternation
      self::Alternation__
    end

    def self.from_ordered_set
      self::From_Ordered_Set__
    end

    def self.from_set
      self::From_Set__
    end

    def self.series * a
      if a.length.zero?
        self::Series__
      else
        self::Series__.via_argument_list a
      end
    end

    def self.strange x
      Strange_[ x ]
    end

    Strange_ = -> x do  # first of family [#050]
      if x.respond_to? :id2name
        "\"#{ x }\""
      elsif ::Proc === x
        x.inspect
      else
        "(#{ x.class })"
      end
    end

    # hack label
    # like so -
    #
    #     P = MetaHell::Parse::Hack_label_
    #     P[ :@foo_bar_x ] # => "foo bar"
    #     P[ :some_method ]  # => "some method"

    Hack_label_ = -> ivar_i do
      MetaHell_::Library_::Headless::Name::FUN::Labelize[ ivar_i ].downcase
    end

    # fuzzy matcher - partial match anchored to beginning
    # it's a proc that generates other procs
    #
    #     P = MetaHell::Parse::Fuzzy_matcher_
    #     Q = P[ 3, 'foobie' ]
    #
    #     Q[ 'f' ] # => nil
    #     Q[ 'foo' ]  # => true
    #     Q[ 'foob' ]  # => true
    #     Q[ 'foobie-doobie' ]  # => nil
    #

    def self.fuzzy_matcher
      Fuzzy_matcher_
    end

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

    module Fields
      module Int
        Scan_token = -> tok do
          RX__ =~ tok and tok.to_i
        end
        RX__ = /\A\d+\z/
      end

      Autoloader_[ self ]
    end
  end
end
