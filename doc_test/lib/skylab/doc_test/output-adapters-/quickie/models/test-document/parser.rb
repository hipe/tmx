module Skylab::DocTest

  module OutputAdapters_::Quickie

    class Models::TestDocument

      o = Home_::Models_::Document::ErsatzParser.begin

      # given a line that opens a branch node, here is how
      # we match the line with the `end` keyword on it

      cache = {}  # don't make a new regex for every time a branch is pushed

      o.default_branch_end_line_matcher_by do |md|
        cache.fetch md[ :margin ] do |s|
          rx = /\A#{ ::Regexp.escape md[ :margin ] }end\b/
          cache[ s ] = rx
          rx
        end
      end

      # --

      identifying_string_via_const = -> md do
        md[ :const ]
      end

      identifying_string_via_quoted_string = -> md do
        ::Kernel._K
      end

      # --

      part = '[A-Z][a-z_A-Z0-9]*'

      const_part = "(?<const>(?:::)?#{ part }(?:::#{ part })*)\\b"

      quoted_string_part = %q(
        (?:
          ' (?<single_quoted_bytes> (?: [^\\'] | \\. )* ) ' |
          " (?<double_quoted_bytes> (?: [^\\"] | \\. )* ) "
        )
      )

      # --

      o.add_branch_line_matcher(
        %r(\A(?<margin>[\t ]*)it[ ]#{ quoted_string_part })x,
        :it,
        & identifying_string_via_quoted_string
      )

      o.add_branch_line_matcher(
        %r(\A(?<margin>[\t ]*)module[ ]#{ const_part }),
        :module,
        & identifying_string_via_const
      )

      o.add_branch_line_matcher(
        %r(\A(?<margin>[\t ]*)describe[ ]#{ quoted_string_part })x,
        :describe,
        & identifying_string_via_quoted_string
      )

      o.add_branch_line_matcher(
        %r(\A(?<margin>[\t ]*)context[ ]#{ quoted_string_part })x,
        :context,
        & identifying_string_via_quoted_string
      )

      PARSER = o.finish
    end
  end
end
