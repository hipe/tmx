module Skylab::DocTest

  class RecursionMagnetics_::
UnitOfWorkStream_via_CounterpartTestIndex_and_ProbablyParticipatingFileStream < Common_::Actor::Dyadic

    def initialize cti, ppfs
      @counterpart_test_index = cti
      @probably_participating_filestream = ppfs
    end

    def execute

      cti = @counterpart_test_index

      @probably_participating_filestream.map_by do |path|

        _details = cti.details_via_asset_path path

        UnitOfWork___.new _details, path
      end
    end

    # ==

    class UnitOfWork___

      def initialize details, path
        @asset_path = path
        @_details = details
      end

      def test_path_is_real
        @_details.is_real
      end

      def test_path
        @_details.to_path
      end

      attr_reader(
        :asset_path,
      )
    end
  end
end
