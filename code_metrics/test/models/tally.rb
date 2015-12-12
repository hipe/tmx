module Skylab::CodeMetrics::TestSupport

  module Models::Tally::Magnetics

    def self.[] tcc

      tcc.include self
    end

    # -

      TestSupport_::Memoization_and_subject_sharing[ self ]

      def stub_match_stream_session_one_

        _cls = magnetics_module_::Match_Stream_via_Vendor_Match_Stream
        o = _cls.new
        o.pattern_strings = [ _THING_ONE, _THING_TWO ]
        o.vendor_match_stream = __vendor_match_stream_stub_one
        o
      end

      memoize :_THING_ONE do 'THING_ONE' end
      memoize :_THING_TWO do 'THING_TWO' end
      memoize :_FILE_A do '/file-A' end
      memoize :_FILE_B do '/file-B' end

      def __vendor_match_stream_stub_one

        Callback_::Stream.via_nonsparse_array ___data_for_stub_one
      end

      define_method :___data_for_stub_one do

        eek = magnetics_module_::Vendor_Match_Stream_via_Files_Slice_Stream::Vendor_Match___

        a = []

        a << eek[ 3, _FILE_A, '  so there is THING_ONE and THING_TWO huzza' ]

        a << eek[ 6, _FILE_A, 'THING_TWO again' ]

        a << eek[ 9, _FILE_A, 'at the end we have THING_ONE' ]

        a << eek[ 2, _FILE_B, 'both THING_ONE and THING_TWO (different file)' ]

        a
      end

      def begin_files_slice_stream_session_

        o = files_slice_stream_session_class_.new( & handle_event_selectively )
        o.chunk_size = 2
        o.system_conduit = Home_.lib_.open_3
        o
      end

      def files_slice_stream_session_class_
        magnetics_module_::Files_Slice_Stream_via_Parameters
      end

      dangerous_memoize :the_asset_directory_for_this_project_ do

        _the_asset_module_for_this_project.dir_pathname.to_path
      end

      def magnetics_module_
        _the_asset_module_for_this_project::Magnetics_
      end

      def _the_asset_module_for_this_project
        Home_::Models_::Tally
      end
    # -
  end
end
