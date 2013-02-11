module Skylab::TanMan

  Models::DotFile::SyntaxNodes || nil           #preload (and see notes in..
  Models::DotFile::Sexp::InstanceMethods || nil #preload  .. <- here aobut this)

  module Models::DotFile::Parser::InstanceMethods
    include TanMan::Parser::InstanceMethods

    ENTITY_NOUN_STEM = 'dot file'

  protected

    def load_parser_class

      on_info = on_load_parser_info
      on_info ||= -> e do
        if verbose_dotfile_parsing
          info "#{ em '^_^' } #{ gsub_path_hack e.to_s }"
        end
      end

      Headless::Services::TreetopTools::Parser::Load.new( self,
        ->(o) do
          force_overwrite? and o.force_overwrite!
          o.generated_grammar_dir generated_grammar_dir
          o.root_for_relative_paths ::File.expand_path('../..', __FILE__)
          o.treetop_grammar 'dot-language-hand-made.treetop'
          o.treetop_grammar 'dot-language.generated.treetop'
        end,
        ->(o) do
           o.on_info(& on_info)
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
      format = -> tf { tf.expected_string.inspect }
      result = nil
      begin
        inside = case a.length
        when 0 ; nil
        when 1 ; format[ a.first ]
        else   ; "one of #{ a.map { |tf| format[tf] }.uniq.join ', ' }"
        end
        inside or break
        result = "expecting #{ inside }"
      end while nil
      result
    end

    def force_overwrite?
      false
    end

    def generated_grammar_dir
      '../../../../../tmp/tan-man'
    end


    def parser_failure_reason

      in_file = -> do
        line_col = "#{ parser.failure_line }:#{ parser.failure_column }"
        s = nil
        if input_adapter.respond_to? :pathname
          s = "In #{ escape_path input_adapter.pathname }:#{ line_col }"
        else
          s = "In #{ input_adapter.entity_noun_stem }:#{ line_col }"
        end
        s
      end.call

      [ in_file, expecting, * excerpt_lines ].compact.join "\n"
    end
  end
end
