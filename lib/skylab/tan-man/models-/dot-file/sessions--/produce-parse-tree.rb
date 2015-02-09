module Skylab::TanMan

  module Models_::DotFile

    Sessions__ = ::Module.new

    class Sessions__::Produce_Parse_Tree

      class Shell < ::BasicObject

        def initialize bx
          @bx = bx
        end

        def generated_grammar_dir_path path
          @bx.add :generated_grammar_dir_path, path
        end

        def input_path path
          @bx.add :parse_method, :parse_file
          @bx.add :parse_argument, path
        end

        def input_string s
          @bx.add :parse_method, :parse_string
          @bx.add :parse_argument, s
        end
      end

      DotFile_::SyntaxNodes.class
      DotFile_::Sexp::InstanceMethods.class

      include TanMan_::Input_Adapters_::Treetop::Parser_Instance_Methods

      def initialize bx, & oes_p
        @bx = bx
        @on_event_selectively = oes_p
      end

      def produce_parse_tree
        h = @bx.h_
        send h.fetch( :parse_method ), h.fetch( :parse_argument ), & @on_event_selectively
      end

      def produce_parser_class  # :#hook-out for [ttt]
        Memoized_parser_class__[] || Memoize_parser_class__[ __build_parser_class ]
      end

      -> do
        cls = nil
        Memoized_parser_class__ = -> { cls }
        Memoize_parser_class__ = -> x { cls = x ; x }
      end.call

      def __build_parser_class

        TanMan_::Input_Adapters_::Treetop::Load.new( self,

          -> o do

            # o.force_overwrite!  will re-write generated parser files

            o.generated_grammar_dir @bx.fetch :generated_grammar_dir_path

            o.root_for_relative_paths Models_::DotFile.dir_pathname.to_path

            o.treetop_grammar 'dot-language-hand-made.treetop'

            o.treetop_grammar 'dot-language.generated.treetop'
          end,

          -> o do

            # one day ..

            o.on_info do | ev |
              @on_event_selectively.call :info, ev.terminal_channel_i do
                ev
              end
            end

            o.on_error do | ev |
              @on_event_selectively.call :error, ev.terminal_channel_i do
                ev
              end
            end

          end ).invoke
      end

      def build_parse_failure_event  # #hook-out for [ttt]
        a = __build_parse_failure_iambic
        build_not_OK_event_via_mutable_iambic_and_message_proc( a, -> y, o do
          line_col = "#{ o.line_no }:#{ o.line_col }"
          y << if o.has_tag :pn
            "In #{ pth o.pn }:#{ line_col }"
          else
            "In #{ o.ens }:#{ line_col }"
          end
          s = o.exp_s and y << s
          o.excerpt_line_a.each do |s_|
            y << s_
          end
        end )
      end

      def __build_parse_failure_iambic
        a = [ :parse_failed ]
        __add_line_and_column a
        __add_pathname_or_ENS a
        a.push :exp_s, __expecting
        a.push :excerpt_line_a, __excerpt_lines
        a
      end

      def __add_pathname_or_ENS a
        if @input_adapter.respond_to? :pathname
          a.push :pn, @input_adapter.pathname
        else
          a.push :ens, @input_adapter.entity_noun_stem
        end
      end

      def __add_line_and_column a
        a.push :line_no, @parser.failure_line
        a.push :line_col, @parser.failure_column
      end

      def __expecting
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

      def __excerpt_lines
        scn = TanMan_.lib_.string_scanner.new parser.input
        stop_at = parser.failure_line
        line_no = 0
        begin
          line_no += 1
          line = scn.scan LINE_CONTENT_RX__
        end until line_no >= stop_at
        margin = " #{ line_no }: "
        [ "#{ margin }#{ line.chomp }",
          "#{ SPACE_ * margin.length }#{ '-' * [0, parser.failure_column - 1].max }^"
        ]
      end

      LINE_CONTENT_RX__ = (/[^\r\n]*$\r?\n?/)

    public  # ~ smaller #hook-in's & #hook-outs for [ttt]

      def receive_parse_failure_event ev
        raise ev.to_exception
      end

      def entity_noun_stem
        ENS__
      end
      ENS__ = 'dot file'.freeze

    end
  end
end
# :+#tombstone: profiling (how long it took)
