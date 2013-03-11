require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Stylize

  ::Skylab::Headless::TestSupport::CLI[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Headless }::CLI::Stylize::Chunker" do

    stylize = Headless::CLI::Pen::FUN.stylize

    parse_styles = Headless::CLI::FUN.parse_styles

    unstylize_sexp = Headless::CLI::FUN.unstylize_sexp

    it "look, wow" do

      styl = "foo #{ stylize[ 'bar', :blue ] } baz"

      sexp = parse_styles[ styl ]

      enum = Headless::CLI::Stylize::Chunker::Enumerator.new sexp
      parts = enum.to_a
      types, strings = parts.reduce [[],[]] do |(tp, st), pt|
        tp << pt[0][0]
        st << unstylize_sexp[ pt ]
        [ tp, st ]  # just cute not good
      end
      types.should eql( [ :string, :style, :string] )
      strings.should eql( ["foo ", "bar", " baz"] )
    end
  end
end
