module Skylab::DocTest

  module OutputAdapters_::Quickie

    class Models::TestDocument

      class << self

        def parse_line_stream st  # #testpoint-only

          Here_::PARSER.parse_line_stream st
        end
      end  # >>

      Here_ = self
    end
  end
end
