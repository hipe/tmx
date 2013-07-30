module Skylab::MetaHell

  module FUN::Parse

    Strange_ = -> x do
      x.respond_to?( :id2name ) ? "\"#{ x }\"" : "(#{ x.class })"
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
