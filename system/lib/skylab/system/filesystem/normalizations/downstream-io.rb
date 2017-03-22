module Skylab::System

  module Filesystem

    class Normalizations::Downstream_IO < Normalizations::PathBased  # :[#004.D]
    private

      def initialize
        @_force_arg = nil
        @_is_dry_run = false
        @_stderr = nil
        @_stdout = nil
        super
      end

      def dash_means=
        @dash_means_ = gets_one
        KEEP_PARSING_
      end

      def force_arg=
        @_force_arg = gets_one
        KEEP_PARSING_
      end

      def is_dry_run=
        @_is_dry_run = gets_one
        KEEP_PARSING_
      end

      def stderr=
        @_stderr = gets_one
        KEEP_PARSING_
      end

      def stdout=
        @_stdout = gets_one
        KEEP_PARSING_
      end

      public def execute

        # note this is only superficially similar to [#here.A] the common
        # algorithm and should probably not be abstracted

        io = @_stdout
        pa = @qualified_knownness_of_path

        if pa && pa.is_known_known && pa.value_x

          if @do_recognize_common_string_patterns_
            md_x = via_path_arg_match_common_pattern_
          end

          if md_x
            via_common_pattern_match_ md_x
          else
            via_path_arg_that_represents_file_
          end

        elsif io

          produce_result_via_open_IO_ io

        else

          maybe_emit_missing_required_properties_event_
        end
      end

      def when__stderr__by_way_of_dash
        produce_result_via_open_IO_ @_stderr
      end

      def when__stdout__by_way_of_dash
        produce_result_via_open_IO_ @_stdout
      end

      def build_missing_required_properties_event_

        build_not_OK_event_with(
          :missing_required_properties,
          :path_property, @qualified_knownness_of_path.association

        ) do | y, o |

          y << "expecting #{ par o.path_property }"
        end
      end

      def via_system_resource_identifier_ d

        case d
        when 1
          via_stdout_
        when 2
          via_stderr_
        else
          when_invalid_system_resource_identifier_ d, 1, 2
        end
      end

      def via_path_arg_that_represents_file_

        init_exception_and_open_IO_ ::File::RDWR | ::File::CREAT

        if @exception_  # e.g perms, e.g no directory

          __when_exception
        else

          @open_IO_.flock ::File::LOCK_EX | ::File::LOCK_NB
          __via_open_IO_create_or_overwrite
        end
      end

      def __when_exception

        case @exception_
        when ::Errno::ENOENT
          __when_no_dirname

        when ::Errno::ENOTDIR
          # hi. we could clarify this but we don't for now.
          via_exception_produce_result_

        else
          via_exception_produce_result_
        end
      end

      def __when_no_dirname

        # if we tried to create (or overwrite) and we got this, we
        # assume for now that it is because the dirname didn't exist.
        # let's make that message more clear:

        _dir = ::File.dirname path_

        @listener.call :resource_not_found, :parent_directory_must_exist  do

          build_not_OK_event_with(
            :parent_directory_must_exist,
            :path, _dir,
          )
        end
        UNABLE_
      end

      def __via_open_IO_create_or_overwrite

        @stat_ = @open_IO_.stat
        d = @stat_.size
        if d.zero?

          # whether or not the file existed before, we treat this always
          # as a create (it's easier to do so, and practial enough too.)

          __create
        else
          __maybe_overwrite
        end
      end

      def __maybe_overwrite  # assume file existed and had nonzero bytes

        # you've opened a file for RW that has some content in it -
        # appending to it is outside our scope (for now). either you
        # will truncate it and start over from the beginning or you
        # cannot overwrite its content. which it is depends on:

        fa = @_force_arg
        if fa
          if fa.is_known_known && fa.value_x
            _overwrite
          else
            @listener.call :error, :missing_required_properties do
              __build_missing_required_force_event
            end
            UNABLE_
          end
        else
          _overwrite
        end
      end

      def __build_missing_required_force_event

        build_not_OK_event_with(
          :missing_required_permission,
          :force_arg, @_force_arg,
          :qualified_knownness_of_path, @qualified_knownness_of_path,

        ) do | y, o |

          y << "#{ par o.qualified_knownness_of_path.association } #{
           }exists, won't overwrite without #{
            }#{ par o.force_arg.association }: #{
             }#{ pth o.qualified_knownness_of_path.value_x }"
        end
      end

      def __create

        # assume that either the file didn't exist, or existed but
        # was of zero size.

        @listener.call :info, :before_probably_creating_new_file do
          __build_before_probably_creating_new_file_event
        end

        if @_is_dry_run

          # NASTY - until we work this out - #open [#022]

          @filesystem.unlink path_
          produce_result_via_open_IO_ Home_::IO.dry_stub_instance
        else
          produce_result_via_open_IO_ @open_IO_
        end
      end

      def _overwrite  # assume file existed and had nonzero content

        @listener.call :info, :before_editing_existing_file do
          __build_before_editing_existing_file_event
        end

        if @_is_dry_run

          @open_IO_.close
          produce_result_via_open_IO_ Home_::IO.dry_stub_instance

        else

          @open_IO_.rewind
          @open_IO_.truncate 0
          produce_result_via_open_IO_ @open_IO_
        end
      end

      def __build_before_probably_creating_new_file_event

        build_neutral_event_with(
          :before_probably_creating_new_file,
          :qualified_knownness_of_path, @qualified_knownness_of_path,

        ) do | y, o |

          y << "creating #{ pth o.qualified_knownness_of_path.value_x }"
        end
      end

      def __build_before_editing_existing_file_event

        build_neutral_event_with(
          :before_editing_existing_file,
          :qualified_knownness_of_path, @qualified_knownness_of_path,
          :stat, @stat_

        ) do | y, o |

          if o.stat.size.zero?
            _zero_note = " empty file"
          end
          _path = o.qualified_knownness_of_path.value_x

          y << "updating#{ _zero_note } #{ pth _path }"
        end
      end

      def via_exception_produce_result_

        @listener.call :error, :exception do
          wrap_exception_ @exception_
        end
        UNABLE_
      end

      def byte_whichstream_identifier_

        Home_::IO::ByteDownstreamReference
      end

      def which_stream_
        :downstream
      end
    end
  end
end
