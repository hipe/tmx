module Skylab::DocTest::TestSupport

  module Test_Document_Shorthand

    def self.[] tcc
      tcc.include self
    end

    # -

      def first_example_node_

        Stream_of__[ test_document_ ].gets.example_node
      end

      def first_qualified_example_node_with_identifying_string_ s

        first_qualified_example_node_with_identifying_string_in_of_(
          test_document_, s )
      end

      def first_qualified_example_node_with_identifying_string_in_of_ doc, s

        Stream_of__[ doc ].flush_until_detect do |qeg|

          s == qeg.example_node.document_unique_identifying_string
        end
      end

      def to_qualified_example_node_stream_
        Stream_of__[ test_document_ ]
      end

    # -

    # ==

    Stream_of__ = -> doc do

      o = doc.begin_branch_stream_session

      o.branch_stream.map_reduce_by do |branch|

        if :example_node == branch.category_symbol
          Qualified_Example___[ branch, o.current_parent_branch__ ]
        end
      end
    end

    Qualified_Example___ = ::Struct.new :example_node, :parent_branch

    # ==
  end
end
# #history: abstracted from the asset node it tests
