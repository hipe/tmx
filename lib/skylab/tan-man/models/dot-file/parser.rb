require 'skylab/treetop-tools/core'

module Skylab::TanMan
  Models::DotFile::SyntaxNodes and nil # load it here & now
  Models::DotFile::Sexp = ::Skylab::TanMan::Sexp
  module Models::DotFile::Parser end
  module Models::DotFile::Parser::InstanceMethods
    include ::Skylab::TreetopTools::Parser::InstanceMethods
    ENTITY_NOUN_STEM = 'dot file'
  protected
    def load_parser_class
      ::Skylab::TreetopTools::Parser::Load.new(
        ->(o) do
          # o.force_overwrite!
          o.generated_grammar_dir '../../../../../tmp'
          o.root_for_relative_paths ::File.expand_path('..', __FILE__)
          o.treetop_grammar 'dot-language-hand-made.treetop'
          o.treetop_grammar 'dot-language.generated.treetop'
        end,
        ->(o) do
           o.on_info { |e| info "#{em '*'} #{e}" }
           o.on_error { |e| fail("failed to load grammar: #{e}") }
        end
      ).invoke
    end
    # --*--
    def excerpt_lines
      scn = ::StringScanner.new(parser.input) # a ::StringIO is easier,
      stop_at = parser.failure_line           # but this is more fun (powerful?)
      line_no = 0
      begin
        line_no += 1
        line = scn.scan(/[^\r\n]*$\r?\n?/)
      end until line_no >= stop_at
      margin = " #{ line_no }: "
      [ "#{ margin }#{ line.chomp }",
        "#{ ' ' * margin.length }#{ '-' * [0, parser.failure_column - 1].max }^"
      ]
    end
    def expecting
      a = parser.terminal_failures
      format_f = ->(tf) { tf.expected_string.inspect }
      "expecting #{
        case a.length
        when 0 ; return
        when 1 ; format_f[a.first]
        else   ; "one of #{ a.map { |tf| format_f[tf] }.uniq.join(', ') }"
        end
      }"
    end
    def in_file
      "In #{ input_adapter.pathname.pretty }:#{
        parser.failure_line }:#{ parser.failure_column }"
    end
    def parser_failure_reason
      [ in_file, expecting, * excerpt_lines ].compact.join("\n")
    end
  end
end
