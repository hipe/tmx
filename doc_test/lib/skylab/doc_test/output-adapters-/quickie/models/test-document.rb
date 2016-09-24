module Skylab::DocTest

  module OutputAdapters_::Quickie

    class Models::TestDocument

      class << self

        def via_line_stream st  # #testpoint-only

          PARSER.parse_line_stream st
        end
      end  # >>

      o = Home_::ErsatzParser.begin

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

      identifying_string_via_const = -> vs, md, * do

        vs.XXX_SOMETHING1 = md[ :const ]  # #todo-now
      end

      identifying_string_via_quoted_string = -> vs, md, * do

        vs.document_unique_identifying_string =
          Home_::Models_::String.unescape_quoted_string_literal_matchdata md
      end

      # --

      part = '[A-Z][a-z_A-Z0-9]*'

      const_part = "(?<const>(?:::)?#{ part }(?:::#{ part })*)\\b"

      quoted_string_part = Models_::String.quoted_string_regex_part

      # --

      o.add_branch_line_matcher(
        %r(\A(?<margin>[\t ]*)it[ ]#{ quoted_string_part })x,
        :example_node,
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
        :context_node,
        & identifying_string_via_quoted_string
      )

      before_which = -> ss do
        _h = { "all" => :before_all, "each" => :before_each }
        before_which = _h.method :fetch
        before_which[ ss ]
      end

      o.add_branch_line_matcher(
        %r(\A
          (?<margin>[\t ]*)
            before (?:
              \( [\t ]* :(?<a_or_e>[a-zA-Z_]+) [ \t]* \) [ \t]*
            |
                 [\t ]* :(?<a_or_e>[a-zA-Z_]+)[ \t]+
            |
                 [\t ]+
            )
            do\b
        )x,
        :before,

      ) do |vs, md|
        vs.node_internal_identifying_symbol = before_which[ md[ :a_or_e ] ]
      end

      same = '[a-zA-Z_][a-z_A-Z0-9]*'
      o.add_branch_line_matcher(
        %r(\A
          (?<margin>[\t ]*)
            shared_subject(?:
              \( [\t ]* :(?<var_name>#{ same }) [ \t]* \) [ \t]*
            |
                 [\t ]* :(?<var_name>#{ same })[ \t]+
            )
            do\b
        )x,
        :shared_subject,

      ) do |vs, md|

        vs.branch_unique_identifying_string = md[ :var_name ]
      end

      PARSER = o.finish
    end
  end
end
