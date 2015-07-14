require_relative '../../../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] S & R - actors - build replace function", wip: true do

    extend TS_
    # use :expect_event

    it "a replace function can be used for oridnary string substitution" do

      rf 'foo'

      rx %r( Jimbo )x

      against "durfie Jimbo wahootey"

      expect "durfie foo wahootey"

    end

    it "but if you use the mustache open curlies, watch out:" do

      rf "{{"

      expect_event :replace_function_parse_error, unindent(
        "expecting <capture reference> or \"{{\":\n#{
        }\n#{
        }^" )

    end

    it "reference captures with $1, $2 etc" do

      rf "_{{ $1 }}_"

      rx %r(\*  ( [^*]+ )  \*)x

      against "it's *neat*"

      expect "it's _neat_"

    end

    it "if you want to have a literal \"{{\" in your expression:" do

      rf "foo {{ \"{{\" }} "

      rx %r(.)

      against "XY"

      expect 'foo {{ foo {{ '

    end

    it "a limited subset of string methods is supported" do

      rx %r(\b([A-Z][a-z]+\b))

      rf "HI {{ $1.downcase }}."

      against "well Susan"

      expect "well HI susan."

    end

    # some extension API is possible but meh
  end
end
