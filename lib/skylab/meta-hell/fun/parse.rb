module Skylab::MetaHell

  module FUN::Parse

    Strange_ = -> x do
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
    #     P = MetaHell::FUN::Parse::Hack_label_
    #     P[ :@foo_bar_x ] # => "foo bar"
    #     P[ :some_method ]  # => "some method"

    Hack_label_ = -> ivar_i do
      MetaHell::Services::Headless::Name::Labelize[ ivar_i ].downcase
    end

    # fuzzy matcher
    # is a currier - it's a proc that generates other procs
    #
    #     P = MetaHell::FUN::Parse::Fuzzy_matcher_
    #     Q = P[ 3, 'foobie' ]
    #
    #     Q[ 'f' ] # => nil
    #     Q[ 'foo' ]  # => true
    #     Q[ 'foob' ]  # => true
    #     Q[ 'foobie-doobie' ]  # => nil
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

    Parse = self
  end
end
