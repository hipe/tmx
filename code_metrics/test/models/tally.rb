module Skylab::CodeMetrics::TestSupport

  module Models::Tally::Magnetics

    def self.[] tcc

      tcc.include self
    end

    # -

      define_singleton_method :_danger_memo, TestSupport_::DANGEROUS_MEMOIZE

      def begin_files_slice_stream_session_

        o = files_slice_stream_session_class_.new( & handle_event_selectively )
        o.chunk_size = 2
        o.system_conduit = Home_.lib_.open_3
        o
      end

      def files_slice_stream_session_class_
        magnetics_module_::Files_Slice_Stream_via_Parameters
      end

      _danger_memo :the_asset_directory_for_this_project_ do

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
