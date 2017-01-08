require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] - filesystem - pather - abs. path hack (FEATURE ISLAND)" do

    # #feature-island. (this is no longer connected to anything..) #open [#033]

    TS_[ self ]

    say = -> a do

      in_s, out_x = a

      _vp = if out_x
        "sees #{ out_x.inspect }"
      else
        "doesn't see an absolute path"
      end

      "in '#{ in_s }' it #{ _vp }"
    end

    _1 = [ 'foo', nil ]

    it say[ _1 ] do
      _test _1
    end

    _2 = [ 'foo/bar', nil ]

    it say[ _2 ] do
      _test _2
    end

    _3 = [ '/foo/bar', '/foo/bar']

    it say[ _3 ] do
      _test _3
    end

    _4 = [ ' "/foo/bar" ', '/foo/bar' ]

    it say[ _4 ] do
      _test _4
    end

    rx = %r{ (?<= \A | [[:space:]'",] )  (?: / [^[:space:]'",]+ )+ }x

    define_method :_test do |a|
      md = rx.match a.first
      capture = a.last
      if capture
        md[ 0 ] == capture or fail
      else
        md and fail
      end
    end
  end
end
