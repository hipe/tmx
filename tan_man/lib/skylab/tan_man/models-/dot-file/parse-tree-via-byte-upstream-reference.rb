module Skylab::TanMan

  module Models_::DotFile

    class ParseTree_via_ByteUpstreamReference

      Attributes_actor_.call( self,
        byte_upstream_reference: nil,
        generated_grammar_dir_path: nil,
      )

      def initialize & p
        if p
          __init_listener p
        end
      end

      def __init_listener use_p

        # errors like file not found etc (that stem from path math errors)
        # have causes that are so hard to track down we throw them so that
        # the call stack is presented immediately rather than having to hunt

        @listener = -> * sym_a, & ev_p do
          if :error == sym_a.first && :stat_error == sym_a[ 1 ]
            raise ev_p[].exception
          else
            use_p[ * sym_a, & ev_p ]
          end
        end ; nil
      end

      Here_.const_get :SyntaxNodes, false
      Here_.const_get :RuleEnhancements, false

      def execute

        x = Home_::InputAdapters_::Treetop::Parse_via_ByteUpstreamReference_and_ParserClass.call_by do |o|

          o.receive_byte_upstream_reference @byte_upstream_reference

          o.accept_parser_class produce_parser_class_

          o.execute_using :flush_to_parse_tree

          o.listener = @listener
        end

        if x
          x
        else
          x  # hi. #cov11.1
        end
      end

      def produce_parser_class_
        Memoized_parser_class__[] || Memoize_parser_class__[ __require_parser_class ]
      end

      -> do
        cls = nil
        Memoized_parser_class__ = -> { cls }
        Memoize_parser_class__ = -> x { cls = x ; x }
      end.call

      def __require_parser_class

        _listener = -> * sym_a, & ev_p do

          # (half of a #[#co-045])

          if :error == sym_a.first
            raise ev_p[].to_exception
          else
            @listener.call( * sym_a, & ev_p )
          end
        end

        Home_::InputAdapters_::Treetop::RequireGrammars_via_Paths.call_by do |o|

          _path = Models_::DotFile.dir_path

          o.input_path_head_for_relative_paths = _path

          o.output_path_head_for_relative_paths = @generated_grammar_dir_path

          o.add_treetop_grammar 'dot-language-hand-made.treetop'

          o.add_treetop_grammar 'dot-language.generated.treetop'

          # o.force_overwrite!  # re-writes generated parser files - use only when syntax changes
          o.listener = _listener
        end
      end

      def build_parse_failure_event  # #hook-out for [ttt]
        a = __build_parse_failure_iambic
        build_not_OK_event_via_mutable_iambic_and_message_proc( a, -> y, o do
          line_col = "#{ o.line_no }:#{ o.line_col }"
          y << if o.has_member :pn
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
        scn = Home_.lib_.string_scanner.new parser.input
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
