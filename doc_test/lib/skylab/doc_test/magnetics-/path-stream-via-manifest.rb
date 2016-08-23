module Skylab::DocTest

  self._K_will_rewrite

            start_path = if ::File.file? @path  # walks start from dirs always
              ::File.dirname @path
            else
              @path
            end

            @surrounding_path = @filesystem.walk(
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
          end

          def __via_manifest_path_resolve_open_file

            @open_file_IO = @filesystem[ :Upstream_IO ].via_path(
              @manifest_path,
              & @on_event_selectively )

            @open_file_IO && ACHIEVED_
          end
end
# #tombstone: rewrite to simplify away manifest file syntax
# :+#tombstone: back when the search was expressed by dir and file
