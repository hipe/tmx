module Skylab::DocTest::TestSupport

  module Ersatz_Parser

    def self.[] tcc
      tcc.include self
    end

    # -

      TestSupport_::Define_dangerous_memoizer.call self, :grammar_one_parser_ do

        o = ersatz_lib_module_.begin

        # --

        cache = {}  # don't make a new regex for every time a branch is pushed

        o.default_branch_end_line_matcher_by do |md|
          cache.fetch md[ :margin ] do |s|
            x = /\A#{ ::Regexp.escape md[ :margin ] }end\b/
            cache[ s ] = x
            x
          end
        end

        # --

        rx = /\A
          [ \t]+ (?:
            ' (?<single_quoted_bytes> (?: [^\\'] | \\. )* ) ' |
            " (?<double_quoted_bytes> (?: [^\\"] | \\. )* ) "
          )
        /x

        o.add_branch_line_matcher(
          %r(\A(?<margin>[\t ]*)begin\b)

        ) do |md|
          # (separate the easy problem of above from the harder problem here)

          md_ = rx.match md.post_match
          s = md_[ :single_quoted_bytes ] || md_[ :double_quoted_bytes ]
          # (we aren't gonna bother unescaping for now..)
          s
        end

        o.finish
      end

      def ersatz_lib_module_
        Home_::Models_::Document::ErsatzParser
      end
    # -
  end
end
