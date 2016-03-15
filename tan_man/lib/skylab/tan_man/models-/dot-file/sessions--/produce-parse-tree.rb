module Skylab::TanMan

  module Models_::DotFile

    Sessions__ = ::Module.new

    class Sessions__::Produce_Parse_Tree

      Attributes_actor_.call( self,
        byte_upstream_identifier: nil,
        generated_grammar_dir_path: nil,
      )

      def initialize & oes_p
        if oes_p
          @on_event_selectively = oes_p
        end
      end

      DotFile_::SyntaxNodes.class
      DotFile_::Sexp::InstanceMethods.class

      def execute

        o = Home_::Input_Adapters_::Treetop::Sessions::Parse.new(
          & @on_event_selectively )

        o.receive_byte_upstream_identifier @byte_upstream_identifier

        o.accept_parser_class produce_parser_class_

        x = o.flush_to_parse_tree
        if x
          x
        else
          self._COVER_ME_parse_failed
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

        o = Home_::Input_Adapters_::Treetop::Sessions::Require.new(

        ) do | * i_a, & ev_p |

          if :error == i_a.first
            raise ev_p[].to_exception
          else
            @on_event_selectively.call( * i_a, & ev_p )
          end
        end

        # o.force_overwrite!  # re-writes generated parser files - use only when syntax changes

        _path = Models_::DotFile.dir_pathname.to_path

        o.input_path_head_for_relative_paths = _path

        o.output_path_head_for_relative_paths = @generated_grammar_dir_path

        o.add_treetop_grammar 'dot-language-hand-made.treetop'

        o.add_treetop_grammar 'dot-language.generated.treetop'

        o.execute
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
