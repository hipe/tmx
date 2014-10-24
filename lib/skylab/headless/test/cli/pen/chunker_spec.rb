require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Pen

  ::Skylab::Headless::TestSupport::CLI[ self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[hl] CLI pen chunker" do

    stylize = Headless_::CLI.pen.stylize

    parse_styles = Headless_::CLI.parse_styles

    unstyle_sexp = Headless_::CLI.unstyle_sexp

    it "look, wow" do

      styl = "foo #{ stylize[ 'bar', :blue ] } baz"
      sexp = parse_styles[ styl ]
      parts = Headless_::CLI.pen.chunker.scan( sexp ).to_a
      types, strings = parts.reduce [[],[]] do |(tp, st), pt|
        tp << pt[0][0]
        st << unstyle_sexp[ pt ]
        [ tp, st ]  # just cute not good
      end
      types.should eql( [ :string, :style, :string] )
      strings.should eql( ["foo ", "bar", " baz"] )
    end
  end
end
