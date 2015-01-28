module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive

        class Actors__::Produce_manifest_entry_stream

          Callback_::Actor.call self, :properties,

            :path,
            :doc_test_dir,
            :doc_test_files_file,
            :path_prop,
            :on_event_selectively

          # for whatever reason (if any) the *relative* path we are searching
          # for is itself broken into two parts: a relative directory path
          # and relative file path under that relative directory.
          #
          # with the series of paths formed by first the given path and then
          # (if any) each successive parent path within it, we concatenate
          # the first part to this path and see if it exists.
          #
          # if no such path is found once we have iterated this step for the
          # root path, our final result is no match (and perhaps an event).
          #
          # however, with each such path that exists (if any), we then
          # concatenate the second part to this path and in turn see if
          # *that* path exists.
          #
          # if one such path is found then that is our final result. if not
          # then each such attempt at looking for this path that didn't
          # exist (in a directory that did exist), we store each of these
          # failures as we search upwards.
          #
          # by the end if we never found a match but we have stored one or
          # more such events, we will emit those somehow.
          #
          # this splitting of the relative path into two parts may or may
          # not have value, but for now is left intact until we are certain
          # that it does not.

          def initialize
            @filesystem = TestSupport_.lib_.system.filesystem
            super
          end

          def execute
            pth = @path
            width_plus = @doc_test_dir.length + 2  # one for a sep, one for off by one when negative offsets
            @not_found_ev_a = nil
            begin

              ok = resolve_nearest_possible_manifest_dir_pathname_from_path pth
              ok or break
              ok = via_manifest_pathname_resolve_open_upstream_IO
              ok and break

              _found_path = @manifest_dir_pn.to_path
              containing_path = _found_path[ 0 .. - width_plus ]
              start_from_here = ::File.dirname containing_path
              start_from_here == containing_path and break
              pth = start_from_here

              redo
            end while nil

            if ok
              flush
            elsif @not_found_ev_a
              self._DO_ME_when_not_OK ok  # #todo (we have the ev's memoized)
            else
              UNABLE_
            end
          end

          def resolve_nearest_possible_manifest_dir_pathname_from_path start_path

            if ::File.file? start_path
              # the below walk needs a dir not a file
              start_path = ::File.dirname start_path
            end

            surrounding_path = @filesystem.walk(
              :start_path, start_path,
              :filename, @doc_test_dir,  # or join those two
              :ftype, DIRECTORY_FTYPE__,
              :max_num_dirs_to_look, -1,
              :prop, @path_prop,
              :on_event_selectively, @on_event_selectively )

            if surrounding_path
              @manifest_dir_pn = ::Pathname.new( ::File.join surrounding_path, @doc_test_dir )
              ACHIEVED_
            else
              UNABLE_
            end
          end
          DIRECTORY_FTYPE__ = 'directory'.freeze

          def via_manifest_pathname_resolve_open_upstream_IO
            pn = @manifest_dir_pn.join @doc_test_files_file
            pth = pn.to_path
            io = @filesystem.normalization.upstream_IO(
              :path, pth,
              :on_event, -> ev do
                if @not_found_ev_a.nil?
                  @not_found_ev_a = [ ev ]
                else
                  @not_found_ev_a.push ev
                end
                UNABLE_
              end )
            io and begin
              _len = @doc_test_dir.length + 2 + @doc_test_files_file.length  # three parts, 2 separator slashes ick
              @top_path = pth[ 0 .. - ( 1 + _len ) ]
              @upstream_IO = io
              ACHIEVED_
            end
          end

          def flush
            Result__.new @upstream_IO, @top_path
          end

          Result__ = ::Struct.new :lines, :top_path
        end
      end
    end
  end
end
