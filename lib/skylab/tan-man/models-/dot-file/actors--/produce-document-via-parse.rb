module Skylab::TanMan

  module Models_::DotFile

    # #todo this whole node needs a simplification rewrite. make it one actor.

  module Actors__

    module Produce_document_via_parse

      def self.[] p
        kernel = Call_Kernel__.new
        shell = Call_Shell__.new kernel
        p[ shell ]
        kernel.result
      end

      class Call_Shell__ < ::BasicObject

        def initialize kernel
          @kernel = kernel
        end

        def generated_grammar_dir_path path
          @kernel.set_generated_grammar_dir_path path
        end

        def via_path path
          @kernel.set_input_tuple :path, path ; nil
        end

        def via_input_pathname pn
          @kernel.set_input_tuple :pathname, pn ; nil
        end

        def via_input_string s
          @kernel.set_input_tuple :string, s ; nil
        end

        def subscribe & p
          @kernel.subscribe_p_a.push p ; nil
        end
      end

      class Call_Kernel__

        def initialize
          @subscribe_p_a = []
          @generated_grammar_dir_path = nil
          @result_has_been_resolved = false
        end

        attr_reader :subscribe_p_a

        def set_generated_grammar_dir_path x
          @generated_grammar_dir_path = x ; nil
        end

        def set_input_tuple i, x
          @input_i = i ; @input_x = x ; nil
        end

        def result
          @result_has_been_resolved or resolve_result
          @result
        end

      private

        def resolve_result
          @result_has_been_resolved = true
          @parse = Parse__.new do |parse|
            parse.generated_grammar_dir_path @generated_grammar_dir_path
            @subscribe_p_a.each do |p|
              parse.subscribe( & p )
            end
          end
          send :"resolve_result_via_input_#{ @input_i }"
          nil
        end

        def resolve_result_via_input_path
          @result = @parse.parse_file ::Pathname.new @input_x ; nil
        end

        def resolve_result_via_input_pathname
          @result = @parse.parse_file @input_x ; nil
        end

        def resolve_result_via_input_string
          @result = @parse.parse_string @input_x ; nil
        end
      end

      DotFile_::SyntaxNodes.class
      DotFile_::Sexp::InstanceMethods.class

      Subscriptions__ = Callback_::Subscriptions.new(
        :parser_loading_info_event,
        :parser_loading_error_event,
        :parser_error_event )

      class Parse__

        def initialize
          @do_force_overwrite_for_load = false
          @conduit = Subscriptions__.new
          yield self
        end

        def generated_grammar_dir_path x
          @generated_grammar_dir_path = x ; nil
        end

        def subscribe
          yield @conduit
        end

        attr_writer :do_force_overwrite_for_load

        include TanMan_._lib.TTT::Parser::InstanceMethods

      private

        def produce_parser_class  # :#hook-out to [ttt]
          cls = Memoized_parser_class__[]
          cls || Memoize_parser_class__[ build_parser_class ]
        end

        -> do
          cls = nil
          Memoized_parser_class__ = -> { cls }
          Memoize_parser_class__ = -> x { cls = x ; x }
        end.call

        def build_parser_class
          TanMan_._lib.TTT::Parser::Load.new( self,
            -> o do
              do_force_overwrite_for_load and o.force_overwrite!
              o.generated_grammar_dir @generated_grammar_dir_path
              o.root_for_relative_paths root_for_relative_paths_for_load
              add_grammar_paths_to_load o
            end,
            -> o do
              if @conduit.is_subscribed_to_parser_loading_info_event
                o.on_info @conduit.handle_parser_loading_info_event
              end
              if @conduit.is_subscribed_to_parser_loading_error_event
                o.on_error @conduit.handle_parser_loading_error_event
              end
            end
          ).invoke
        end

        def add_grammar_paths_to_load o
          o.treetop_grammar 'dot-language-hand-made.treetop'
          o.treetop_grammar 'dot-language.generated.treetop'
        end

        def do_force_overwrite_for_load
          @do_force_overwrite_for_load
        end

        def root_for_relative_paths_for_load
          Models_::DotFile.dir_pathname.to_path
        end

        def excerpt_lines
          scn = TanMan_._lib.string_scanner.new parser.input
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

        def receive_parse_failure_event ev
          raise ev.to_exception  # #todo
        end

        def build_parse_failure_event
          a = build_parse_failure_iambic
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

        def build_parse_failure_iambic
          a = [ :parse_failed ]
          add_line_and_column a
          add_pathname_or_ENS a
          a.push :exp_s, expecting
          a.push :excerpt_line_a, excerpt_lines
          a
        end

        def add_line_and_column a
          a.push :line_no, @parser.failure_line
          a.push :line_col, @parser.failure_column
        end

        def add_pathname_or_ENS a
          if @input_adapter.respond_to? :pathname
            a.push :pn, @input_adapter.pathname
          else
            a.push :ens, @input_adapter.entity_noun_stem
          end
        end

        def entity_noun_stem
          ENS__
        end
        ENS__ = 'dot file'.freeze

      public

        def parameter_label x, d=nil
          "#{ x.normalized_parameter_name }#{ "[#{ d }]" if d }"
        end

      private


        def __parser_result result
          @result = super
          if profile
            maybe_do_profile
          end
          @result
        end

        def maybe_do_profile
          _is = @input_adapter.type.
            is? TestLib_::TTT[]::Parser::InputAdapter::Types::FILE
          if _is
            do_profile
          end
        end

        def do_profile
          d = parse_time_elapsed_seconds * 1000
          path = @input_adapter.pathname.basename.to_s
          send_info_string '      (%2.1f ms to parse %s)' % [ d, path ] ; nil
        end
      end
    end
  end
  end
end
