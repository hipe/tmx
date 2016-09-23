module Skylab::DocTest

  module TestSupport::FixtureOutputAdapters::Widget

    # a model [#026] (its spec is experimental)

    class CopulaAssertion

      def initialize stem, _choices
        @_stem = stem
      end

      def to_line

        actual_code_string, expected_code_string, lts = @_stem.to_three_pieces

        "#{ actual_code_string }.must eql #{ expected_code_string }#{ lts }"
      end
    end
  end
end
