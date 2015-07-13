module Skylab::System

  class Services___::Filesystem

    class Sessions_::Tmpfile_Sessioner

      # ->

        # produce an empty tmpfile open for reading and writing that (through
        # nonblocking calls to `flock`) "belongs to" this process and no
        # other (for participating others). this scales out to N processes
        # all writing to tempfiles from this same straightformward means:
        # with the tempfiles with names like '000' thru N-1, any first such
        # file than can be locked is truncated and yielded; or we fail with
        # an exception.
        #
        # the objective of all this is to free the client from having to
        # worry about what path to use for a tmpfile and whether or not the
        # tmpfile will be written to by other processes; all in a manner that
        # can scale without extra maintenence.
        #
        # because these files are effectively pooled resources that are
        # leased to the client temporarily, the only way to get the tempfile
        # is through the `session` block.

        def initialize
          @_max_number_of_simulatenous_files = 3  # etc
        end

        # ~ writers

        def tmpdir_path s
          @_tmpdir_path = s
          NIL_
        end

        def max_number_of_simultaneous_tmpfiles d

          unless d.respond_to? :bit_length and 0 < d  # otherwise nasty
            raise ::ArgumentError
          end

          @_max_number_of_simulatenous_files = d
          NIL_
        end

        def create_at_most_N_directories d
          @_create_at_most_N_directories = d
          NIL_
        end

        def using_filesystem fs
          @_FS = fs
          NIL_
        end

        # ~ executor

        def session

          _ok = __resolve_directory
          _ok && begin
            fh = __produce_tmpfile
            fh and begin
              x = yield fh
              if ! fh.closed?
                fh.close
              end
              x
            end
          end
        end

        def __resolve_directory
          _ok = __normalize_depth
          _ok && __create_directory_if_necessary
        end

        def __normalize_depth

          dir = @_tmpdir_path
          number_of_directories_needed_to_create = 0
          ok = true

          begin

            if @_FS.directory? dir
              break
            end

            if @_create_at_most_N_directories == number_of_directories_needed_to_create
              ok = false
              __when_too_many_noent_dirs dir
              break
            end

            dir_ = ::File.dirname dir
            if dir_ == dir
              self._SANITY
            end
            dir = dir_

            number_of_directories_needed_to_create += 1
            redo
          end while nil

          @number_of_directories_needed_to_create = number_of_directories_needed_to_create
          ok
        end

        def __when_too_many_noent_dirs dir

          _ev = Callback_::Event.inline_not_OK_with(
              :must_exist,
              :directory, dir,
              :error_category, :errno_enoent )

          raise _ev.to_exception
        end

        def __create_directory_if_necessary

          if @number_of_directories_needed_to_create.zero?
            ACHIEVED_
          else

            dir = @_tmpdir_path
            stack = [ dir ]

            ( @number_of_directories_needed_to_create - 1 ).times do

              dir = ::File.dirname dir
              stack.push dir

            end

            ok = true
            did_a = []

            @number_of_directories_needed_to_create.times do

              path = stack.pop
              ok = @_FS.mkdir path  # :+#would-emit-events
              ok or break
              did_a.push path
            end

            ok && did_a
          end
        end

        def __produce_tmpfile

          max = @_max_number_of_simulatenous_files

          _ = Home_.lib_.basic::Number.of_digits_in_positive_integer max
          fmt = "%0#{ _ }d"
          fs = @_FS
          pth = @_tmpdir_path

          fh = false
          num_files_open = 0

          begin

            _path = ::File.join pth, fmt % num_files_open  # "00", "01", etc

            fh_ = fs.open _path, ::File::CREAT | ::File::RDWR

            es_ = fh_.flock ::File::LOCK_EX | ::File::LOCK_NB

            if es_

              if es_.nonzero?
                self._NEVER_BEEN_COVERED
              end

              #  we succeeded in getting the global lock. done

              es_ = fh_.truncate 0  # we may need to cleanup a previous one
              if es_.nonzero?
                self._NEVER_BEEN_COVERED
              end

              fh = fh_
              break
            end

            # assume the file is open by another process.

            fh_.close

            num_files_open += 1

            if max == num_files_open
              __when_reached_max
              break
            end

            redo
          end while nil

          fh
        end

        def __when_reached_max

          raise ::RuntimeError,
            "reached max number of simultaneous tmpfiles #{
             }(there appear to be #{ @_max_number_of_simulatenous_files } #{
              }open nearly simultaneously)"
        end
        # <-
    end
  end
end
