module Skylab::DocTest::TestSupport

  module My_API

    def self.[] tcc
      Home_.lib_.zerk.test_support::API[ tcc ]
      tcc.include self
    end

    # -

      THIS_METHOD___ = def _DEBUG_AND_EXIT
        io = debug_IO
        root_ACS_result.each do |line|
          io.puts line
        end
        io.puts "(exiting because #{ THIS_METHOD___ } was called.)"
        exit 0
      end

      # --

      def expect_unindented_at_ d, big_s

        big_s.unindent

        _expected_line_stream = Line_stream_via_string_[ big_s ]

        _actual_doc_node = document_node_tuple_.fetch d

        nodes = _actual_doc_node.nodes

        _margin = nodes.fetch(0).get_margin

        demarginator_rx = /\A#{ ::Regexp.escape _margin }/

        _actual_st = Stream_[ nodes ].map_by do |node|

          s = node.line_string
          if Home_::ZERO_LENGTH_LINE_RX_ =~ s
            s
          else
            demarginator_rx.match( s ).post_match
          end
        end

        TestSupport_::Expect_Line::Streams_have_same_content.call(
          _actual_st, _expected_line_stream, self )

        NIL
      end

      # --

      def n_significant_nodes_from_only_context_node_via_result_ d

        _ctxt = only_context_node_via_result_
        a = _ctxt.nodes
        a = filter_endcaps_and_blank_lines_common_ a
        d == a.length || fail
        a
      end

      def filter_endcaps_and_blank_lines_common_ a
        last = a.length - 2
        d = 1
        a_ = []
        begin
          :blank_line == a.fetch( d ).category_symbol || fail
          d += 1
          a_.push a.fetch d
          last == d && break
          d += 1
          redo
        end while above
        a_
      end

      def only_context_node_via_result_

        only_describe_node_via_result_.only_one_via_category_symbol :context_node
      end

      def only_describe_node_via_result_

        _st = root_ACS_result

        _doc = test_document_via_line_stream_ _st

        _doc.only_one :module, :describe
      end

      def my_API_common_generate_ h  # mutates h

        if ! h.key? :output_adapter
          h[ :output_adapter ] = :quickie
        end

        x_a = [ :synchronize ]
        h.each_pair do |k, x|
          x_a.push k, x
        end
        call_via_iambic x_a
      end

      # -- (a little odd here but meh)

      def scan_all_examples_ o

        example_count = 0

        @line_scanner = o

        it_rx = /\A(?<margin>(?:  ){1,})it \"/

        begin
          d = o.skip_blank_lines
          if 1 == d
            md = it_rx.match o.line
            if md
              o.advance_until_line_that_equals "#{ md[ :margin ] }end\n"
              example_count += 1
              redo
            end
            fail __say_not_an_example
          end

        end while nil

        remove_instance_variable :@line_scanner

        Summary_of_ScanAllExamples___.new example_count
      end

      Summary_of_ScanAllExamples___ = ::Struct.new :example_count

      def __say_not_an_example
        "not an example #{ @line_scanner.at_where 'near' }"
      end

      def subject_API
        Home_::API
      end
    # -
  end
end
