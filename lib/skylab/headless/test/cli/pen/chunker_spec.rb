require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Pen

  ::Skylab::Headless::TestSupport::CLI[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[hl] CLI pen chunkder" do

    stylize = Headless::CLI::Pen::FUN.stylize

    parse_styles = Headless::CLI::FUN::Parse_styles

    unstyle_sexp = Headless::CLI::FUN::Unstyle_sexp

    it "look, wow" do

      styl = "foo #{ stylize[ 'bar', :blue ] } baz"

      sexp = parse_styles[ styl ]

      enum = Headless::CLI::Pen::Chunker::Enumerator.new sexp
      parts = enum.to_a
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
