module Skylab::System

  class Services___::Filesystem

    class Normalizations_::Downstream_IO < Normalizations_::Path_Based  # :[#004.D]
    private

      def initialize _fs
        @_force_arg = nil
        @_is_dry_run = false
        @_stderr = nil
        @_stdout = nil
        super _fs
      end

      def dash_means=
        @dash_means_ = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def force_arg=
        @_force_arg = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def is_dry_run=
        @_is_dry_run = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def ftype=
        @_ftype = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def stderr=
        @_stderr = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def stdout=
        @_stdout = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      public def execute

        # note this is only superficially similar to [#.A] the common
        # algorithm and should probably not be abstracted

        io = @_stdout
        pa = @path_arg

        if pa && pa.is_known && pa.value_x

          via_applicable_path_arg_

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
          :path_property, @path_arg.model

        ) do | y, o |

          y << "expecting #{ par o.path_property }"
        end
      end

      def via_applicable_path_arg_

        if @do_recognize_common_string_patterns_
          md_x = via_path_arg_match_common_pattern_
        end

        if md_x
          via_common_pattern_match_ md_x
        else
          __create_or_overwrite
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

      def __create_or_overwrite

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

        maybe_send_event :resource_not_found, :parent_directory_must_exist  do

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
          if fa.is_known && fa.value_x
            _overwrite
          else
            maybe_send_event :error, :missing_required_properties do
              __build_missing_required_force_event
            end
          end
        else
          _overwrite
        end
      end

      def __build_missing_required_force_event

        build_not_OK_event_with(
          :missing_required_permission,
          :force_arg, @_force_arg,
          :path_arg, @path_arg,

        ) do | y, o |

          y << "#{ par o.path_arg.model } #{
           }exists, won't overwrite without #{
            }#{ par o.force_arg.model }: #{
             }#{ pth o.path_arg.value_x }"
        end
      end

      def __create

        # assume that either the file didn't exist, or existed but
        # was of zero size.

        maybe_send_event :info, :before_probably_creating_new_file do
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

        maybe_send_event :info, :before_editing_existing_file do
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
          :path_arg, @path_arg,

        ) do | y, o |

          y << "creating #{ pth o.path_arg.value_x }"
        end
      end

      def __build_before_editing_existing_file_event

        build_neutral_event_with(
          :before_editing_existing_file,
          :path_arg, @path_arg,
          :stat, @stat_

        ) do | y, o |

          if o.stat.size.zero?
            _zero_note = " empty file"
          end
          _path = o.path_arg.value_x

          y << "updating#{ _zero_note } #{ pth _path }"
        end
      end

      def via_exception_produce_result_

        maybe_send_event :error, :exception do
          wrap_exception_ @exception_
        end
      end

      def byte_whichstream_identifier_

        Home_::IO::Byte_Downstream_Identifier
      end

      def which_stream_
        :downstream
      end
    end
  end
end
