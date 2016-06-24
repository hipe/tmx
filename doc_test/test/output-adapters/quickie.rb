module Skylab::DocTest::TestSupport

  module Output_Adapters::Quickie

    def self.[] tcc
      tcc.include self
    end  # >>

    # -

      def output_adapter_test_document_parser_
        output_adapter_module_::Models::TestDocument::PARSER
      end

      def output_adapter_module_
        output_adapters_module_::Quickie
      end
    # -
  end
end
