module Skylab::Parse::TestSupport

  module Iambic_Grammar

    class << self
      def [] tcc
        tcc.include InstaceMethods__
      end
    end  # >>

    # ==

    InstaceMethods__ = self

    class Client

      include InstaceMethods__  # could get you in trouble depending

      def initialize x_a, tc
        @SCANNER = Common_::Scanner.via_array x_a
        @_test_context = tc
      end

      def subject_grammar
        @_test_context.subject_grammar
      end
    end

    # ==

    # -

      def flush_to_item_stream_expecting_all_items_are sym

        _st = flush_to_stream

        _st.map_by do |qual_item|

          qual_item.injection_identifier == sym or fail __say_noeq( qual_item, sym )
          qual_item.item
        end
      end

      def __say_noeq qual_item
        "expected '#{ k }' had '#{ qual_item.injection_identifier }'"
      end

      def flush_to_stream

        _scn = remove_instance_variable :@SCANNER
        _sub = subject_grammar
        _sub.stream_via_scanner _scn
      end

      def against * x_a
        @SCANNER = Common_::Scanner.via_array x_a
      end

      def iambic_grammar_library_module
        Home_::IambicGrammar
      end
    # -

    # ==
    # ==
    # ==
  end
end
# #born: years later
