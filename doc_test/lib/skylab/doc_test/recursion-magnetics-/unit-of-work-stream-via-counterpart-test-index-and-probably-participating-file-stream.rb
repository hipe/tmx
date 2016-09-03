module Skylab::DocTest

  class RecursionMagnetics_::UnitOfWorkStream_via_CounterpartTestIndex_and_ProbablyParticipatingFileStream

    # exactly [#005]

    # non-declared parameters: list (the flag), filesystem

    class << self

      def of rsx
        call(
          rsx.counterpart_test_index,
          rsx.probably_participating_file_stream,
          rsx.list,
          rsx.VCS_reader,
          rsx.filesystem,
          & rsx.listener_
        )
      end

      def call *a, &p
        new( *a, &p ).execute
      end

      alias_method :[], :call
      private :new
    end  # >>

    def initialize cti, ppfs, do_list, vcs_rdr, fs, &p

      @counterpart_test_index = cti
      @do_list = do_list
      @filesystem = fs
      @probably_participating_file_stream = ppfs
      @VCS_reader = vcs_rdr
      @_on_event_selectively = p
    end

    def execute

      proto = RecursionModels_::UnitOfWork.prototype(
        @do_list,
        @VCS_reader,
        @filesystem,
        & @_on_event_selectively
      )

      cti = @counterpart_test_index

      @probably_participating_file_stream.map_by do |path|

        _details = cti.details_via_asset_path path

        proto.new _details, path
      end
    end
  end
end
