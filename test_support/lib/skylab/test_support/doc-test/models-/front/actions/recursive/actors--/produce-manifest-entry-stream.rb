module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive

        class Actors__::Produce_manifest_entry_stream

          Attributes_actor_.call( self,
            :path,
            :doc_test_files_file,
            :path_prop,
          )

          def initialize
            @filesystem = Home_.lib_.system.filesystem
            super
          end

          def execute

            ok = __resolve_manifest_path
            ok &&= __via_manifest_path_resolve_open_file
            ok && __build_result
          end

          def __resolve_manifest_path

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

          def __build_result

            Result___.new @open_file_IO, @manifest_path, @surrounding_path
          end

          Result___ = ::Struct.new :open_file_IO, :manifest_path, :surrounding_path
        end
      end
    end
  end
end
# :+#tombstone: back when the search was expressed by dir and file
