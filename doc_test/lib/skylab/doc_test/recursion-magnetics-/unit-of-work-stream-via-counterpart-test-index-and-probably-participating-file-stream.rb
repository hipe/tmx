module Skylab::DocTest

  class RecursionMagnetics_::UnitOfWorkStream_via_CounterpartTestIndex_and_ProbablyParticipatingFileStream

    # exactly [#005]

    # non-declared parameters: none

    class << self

      def of rsx
        call rsx.counterpart_test_index, rsx.probably_participating_file_stream
      end

      def call *a
        new( *a ).execute
      end

      alias_method :[], :call
      private :new
    end  # >>

    def initialize cti, ppfs
      @counterpart_test_index = cti
      @probably_participating_file_stream = ppfs
    end

    def execute

      cti = @counterpart_test_index

      @probably_participating_file_stream.map_by do |path|

        _details = cti.details_via_asset_path path

        RecursionModels_::UnitOfWork.new _details, path
      end
    end
  end
end
