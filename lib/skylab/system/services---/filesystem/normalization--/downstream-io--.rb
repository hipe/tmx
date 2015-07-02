module Skylab::System

  class Services___::Filesystem

    class Normalization__

      class Downstream_IO__ < self  # near [#004]

        extend Common_Module_Methods_

        Callback_::Actor.methodic self, :properties,
          :properties,
          :dash_means,
          :force_arg,
          :is_dry_run,
          :last_looks

      private

      # -> 2

            def ftype=
              @ftype = gets_one_polymorphic_value
              KEEP_PARSING_
            end

            def path=
              @do_execute = true
              @path_arg = Callback_::Qualified_Knownness.via_value_and_variegated_symbol(
                gets_one_polymorphic_value, :path )
              KEEP_PARSING_
            end

            def path_arg=
              @do_execute = true
              @path_arg = gets_one_polymorphic_value
              KEEP_PARSING_
            end

            def outstream=
              @do_execute = true
              @outstream = gets_one_polymorphic_value
              KEEP_PARSING_
            end

            def on_event=
              oe_p = gets_one_polymorphic_value
              @on_event_selectively = -> *, & ev_p do
                oe_p[ ev_p[] ]
              end
              KEEP_PARSING_
            end

            def result_in_IO_stream_identifier_trio=
              @do_result_in_IO_stream_identifier_trio = true
              KEEP_PARSING_
            end

            # <- 1

          def initialize & edit_p
            @dash_means = nil
            @do_execute = false
            @do_recognize_common_string_patterns = false
            @do_result_in_IO_stream_identifier_trio = nil
            @force_arg = nil
            @ftype = FILE_FTYPE
            @is_dir_mode = false
            @is_dry_run = false
            @last_looks = nil
            @outstream = nil
            @on_event_selectively = nil
            @path_arg = nil
            instance_exec( & edit_p )
            @as_normal_value ||= IDENTITY_
          end

          public def produce_mixed_result_
            if @do_execute
              execute  # is inline normalization
            else
              freeze  # is curried normalization (not implemented)
            end
          end

          public def execute

            @path = if @path_arg && @path_arg.is_known
              @path_arg.value_x
            end
            if @path
              via_path
            elsif @outstream
              @as_normal_value[ @outstream ]
            elsif @path_arg
              when_neither
            end
          end

          def when_neither

            maybe_send_event :error, :missing_required_properties do
              bld_missing_path_event
            end
          end

          def bld_missing_path_event

            build_not_OK_event_with :missing_required_properties,
                :path_property, @path_arg.model do |y, o|
              y << "expecting #{ par o.path_property }"
            end
          end

          def via_path

            if @do_recognize_common_string_patterns
              md_x = via_path_arg_match_common_pattern_
            end

            if md_x
              via_common_pattern_match_ md_x
            else
              path_exists_and_set_stat_and_stat_error @path  # #note-76
              _via_stat
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

          def _via_stat

            if @stat
              when_stat
            else
              when_no_stat
            end
          end

          def when_no_stat

            send :"when_no_stat_for_#{ @ftype }"
          end

          def when_no_stat_for_directory

            __send_creating_event_for_directory

            d = if @is_dry_run
              0
            else
              ::Dir.mkdir @path
            end
            if d.zero?
              @as_normal_value[ @path ]
            else
              self._COVER_ME
            end
          end

          def when_no_stat_for_file

            dir = ::File.dirname @path

            if ::File.directory? dir
              __go
            else
              __when_no_dirname dir
            end
          end

          def __when_no_dirname dir

            maybe_send_event :resource_not_found, :parent_directory_must_exist  do
              build_not_OK_event_with :parent_directory_must_exist, :path, dir
            end
            UNABLE_
          end

          def __go

            __send_creating_event_for_file

            if @is_dry_run
              @as_normal_value[ Home_::IO.dry_stub_instance ]
            else
              via_hopefully_still_available_path_open_file
            end
          end

          def when_stat

            send :"when_stat_for_#{ @ftype }"
          end

          def when_stat_for_directory

            maybe_send_event :error, :directory_exists do
              build_not_OK_event_with :directory_exists, :path, @path
            end
          end

          def when_stat_for_file

            if @force_arg
              if @force_arg.is_known && @force_arg.value_x
                when_stat_is_file_OK_to_overwrite
              else
                via_force_arg_not_OK_to_overwrite
              end
            else
              when_stat_is_file_OK_to_overwrite
            end
          end

          def via_force_arg_not_OK_to_overwrite

            maybe_send_event :error, :missing_required_properties do
              __build_missing_force_event
            end
          end

          def __build_missing_force_event

            build_not_OK_event_with :missing_required_permission,
                :force_arg, @force_arg, :path_arg, @path_arg do |y, o|

              y << "#{ par o.path_arg.model } #{
               }exists, won't overwrite without #{
                }#{ par o.force_arg.model }: #{
                 }#{ pth o.path_arg.value_x }"
            end
          end

          def when_stat_is_file_OK_to_overwrite

            snd_updating_event_for_file

            if @is_dry_run
              @as_normal_value[ Home_::IO.dry_stub_instance ]
            else
              via_hopefully_still_occupied_path_open_file
            end
          end

          # ~ pairs

          def __send_creating_event_for_file

            maybe_send_event :info, :before_probably_creating_new_file do
              __build_BPCNF_event_for_file
            end
          end

          def __build_BPCNF_event_for_file

            build_neutral_event_with :before_probably_creating_new_file,
                :path_arg, @path_arg do |y, o|

              y << "creating #{ pth o.path_arg.value_x }"
            end
          end

          def __send_creating_event_for_directory

            maybe_send_event :info, :creating_directory do
              build_neutral_event_with :creating_directory,
                :path, @path, :path_arg, @path_arg
            end
          end

          def snd_updating_event_for_file

            maybe_send_event :info, :before_editing_existing_file do
              bld_BEEF_event_for_file
            end
          end

          def bld_BEEF_event_for_file

            build_neutral_event_with :before_editing_existing_file,
                :path_arg, @path_arg, :stat, @stat do |y, o|

              if o.stat.size.zero?
                _zero_note = " empty file"
              end
              _path = o.path_arg.value_x

              y << "updating#{ _zero_note } #{ pth _path }"
            end
          end

          def via_hopefully_still_available_path_open_file

            set_IO_and_exception_via_open_mode ::File::CREAT | ::File::WRONLY

            if @IO
              if @do_result_in_IO_stream_identifier_trio
                via_trueish_IO_stream_ @IO
              else
                @as_normal_value[ @IO ]
              end
            else

              maybe_send_event :error, :exception do
                wrap_exception @e
              end
            end
          end

          def byte_whichstream_identifier_

            Home_::IO::Byte_Downstream_Identifier
          end

          def via_hopefully_still_occupied_path_open_file

            set_IO_and_exception_via_open_mode 'r+'
            if @e
              maybe_send_event :error, :exception do
                wrap_exception @e
              end
            else
              if @last_looks
                via_IO_last_looks
              else
                @as_normal_value[ @IO ]
              end
            end
          end

          # ~ support

          def when_last_looks

            _ev = build_neutral_event_with :for_last_looks,
              :IO, @IO, :path, @path, :stat, @stat

            is_ok = false
            x = @last_looks.call _ev, -> do
              is_ok = true ; nil
            end, -> ev do
              maybe_send_event do
                ev
              end
            end
            if is_ok
              @IO.rewind
              @as_normal_value[ @IO ]
            else
              @IO.close
              x
            end
          end

          def set_IO_and_exception_via_open_mode d

            @IO = ::File.open @path, d
            @e = nil

          rescue ::SystemCallError => @e  # Errno::EISDIR, Errno::ENOENT etc
            @IO = false
            nil
          end

          def wrap_exception e

            Callback_::Event.wrap.exception e, :path_hack,
              :properties, :path_arg, @path_arg
          end

          def which_stream_
            :downstream
          end

          # <-
      end
    end
  end
end
