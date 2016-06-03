require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - (80) build replace function" do

    TS_[ self ]
    use :expect_event
    use :SES_replace_function  # 1x

    it "a replace function can be used for oridnary string substitution" do

      rf_ 'foo'

      rx_ %r( Jimbo )x

      against_ "durfie Jimbo wahootey"

      expect_ "durfie foo wahootey"
    end

    it "but if you use the mustache open curlies, watch out:" do

      rf_ "{{"

      expect_event :replace_function_parse_error,
        "expecting <capture reference> or \"{{\":\n#{
        }\n#{
        }^"

    end

    it "reference captures with $1, $2 etc" do

      rf_ "_{{ $1 }}_"

      rx_ %r(\*  ( [^*]+ )  \*)x

      against_ "it's *neat*"

      expect_ "it's _neat_"

    end

    it "if you want to have a literal \"{{\" in your expression:" do

      rf_ "foo {{ \"{{\" }} "

      rx_ %r(.)

      against_ "XY"

      expect_ 'foo {{ foo {{ '

    end

    it "a limited subset of string methods is supported" do

      rx_ %r(\b([A-Z][a-z]+\b))

      rf_ "HI {{ $1.downcase }}."

      against_ "well Susan"

      expect_ "well HI susan."

    end
  end
end
