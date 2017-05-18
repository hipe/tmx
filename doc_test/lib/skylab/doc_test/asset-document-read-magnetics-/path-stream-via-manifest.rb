module Skylab::DocTest

  self._K_will_rewrite  # #open #[#041]

            start_path = if ::File.file? @path  # walks start from dirs always
              ::File.dirname @path
            else
              @path
            end

            @surrounding_path = Home_.lib_.system_lib::Filesystem::Walk.via(
              :start_path, start_path,
              :filename, @doc_test_files_file,
              :ftype, @filesystem.constants::FILE_FTYPE,
              :max_num_dirs_to_look, -1,
              :prop, @path_prop,
              & @on_event_selectively )

            if @surrounding_path
              @manifest_path = ::File.join @surrounding_path, @doc_test_files_file
              ACHIEVED_
            else
              UNABLE_
            end

          def __via_manifest_path_resolve_open_file

            kn = Home_.lib_.system_lib::Filesystem::Normalizations::Upstream_IO.via(
              :path, @matnifest_path,
              :filesystem, etc,
              & @on_event_selectively )

            if kn
              @open_file_IO = kn.value ; ACHIEVED_
            else
              kn
            end
          end
end
# #tombstone: rewrite to simplify away manifest file syntax
# :+#tombstone: back when the search was expressed by dir and file
