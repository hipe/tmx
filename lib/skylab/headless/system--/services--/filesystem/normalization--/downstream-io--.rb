module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Normalization__

        class Downstream_IO__ < self  # see [#022]:##write

          extend Common_Module_Methods_

          Entity_.call self do

            o :iambic_writer_method_name_suffix, :'='

            def path=
              @do_execute = true
              @path_arg = Headless_::Lib_::Bsc_[].trio.
                via_value_and_variegated_symbol iambic_property, :path
            end

            def outstream=
              @do_execute = true
              @outstream = iambic_property
            end

            o :properties, :last_looks, :force_arg,
                :is_dry_run, :on_event

          end

          def initialize & p
            @do_execute = false
            @force_arg = nil
            @is_dry_run = false
            @last_looks = nil
            @outstream = nil
            @path_arg = nil
            instance_exec( & p )
            @as_normal_value ||= IDENTITY_
          end

          def produce_mixed_result
            if @do_execute
              execute  # is inline normalization
            else
              freeze  # is curried normalization (not implemented)
            end
          end

          def execute
            @path = if @path_arg
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
            _ev = build_not_OK_event_with :missing_required_properties,
                :path_property, @path_arg.property do |y, o|
              y << "expecting #{ par o.path_property }"
            end
            send_event _ev
          end

          def via_path
            path_exists_and_set_stat_and_stat_error @path  # #note-76
            if @stat
              when_stat
            else
              when_no_stat
            end
          end

          def when_no_stat
            snd_creating_event
            if @is_dry_run
              @as_normal_value[ Headless_::IO.dry_stub_instance ]
            else
              via_hopefully_still_available_path_open_file
            end
          end

          def when_stat
            if @force_arg
              if @force_arg.value_x
                when_stat_is_file_OK_to_overwrite
              else
                via_force_arg_not_OK_to_overwrite
              end
            else
              when_stat_is_file_OK_to_overwrite
            end
          end

          def via_force_arg_not_OK_to_overwrite

            _ev = build_not_OK_event_with :missing_required_permission,
                :force_arg, @force_arg, :path_arg, @path_arg do |y, o|

              y << "#{ par o.path_arg.property } #{
               }exists, won't overwrite without #{
                }#{ par o.force_arg.property }: #{
                 }#{ pth o.path_arg.value_x }"
            end

            @on_event[ _ev ]
          end

          def when_stat_is_file_OK_to_overwrite
            snd_updating_event

            if @is_dry_run
              @as_normal_value[ Headless_::IO.dry_stub_instance ]
            else
              via_hopefully_still_occupied_path_open_file
            end
          end

          # ~ pairs

          def snd_creating_event
            _ev = build_neutral_event_with :before_probably_creating_new_file,
                :path_arg, @path_arg do |y, o|

              y << "creating #{ pth o.path_arg.value_x }"
            end
            send_event _ev ; nil
          end

          def snd_updating_event
            _ev = build_neutral_event_with :before_editing_existing_file,
                :path_arg, @path_arg, :stat, @stat do |y, o|

              if o.stat.size.zero?
                _zero_note = " empty file"
              end
              _path = o.path_arg.value_x

              y << "updating#{ _zero_note } #{ pth _path }#{ _zero_note }"
            end
            send_event _ev ; nil
          end

          def via_hopefully_still_available_path_open_file
            set_IO_and_exception_via_open_mode WRITE_MODE_
            if @IO
              @as_normal_value[ @IO ]
            else
              @on_event[ wrap_exception @e ]
            end
          end

          def via_hopefully_still_occupied_path_open_file
            set_IO_and_exception_via_open_mode 'r+'
            if @e
              @on_event[ wrap_exception @e ]
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
              @on_event[ ev ]
            end
            if is_ok
              @IO.rewind
              @as_normal_value[ @IO ]
            else
              @IO.close
              x
            end
          end

          def set_IO_and_exception_via_open_mode s
            @IO = ::File.open @path, s
            @e = nil
          rescue ::SystemCallError => @e  # Errno::EISDIR, Errno::ENOENT etc
            @IO = false
            nil
          end

          def wrap_exception e
            Event_.wrap.exception e, :path_hack,
              :properties, :path_arg, @path_arg
          end
        end
      end
    end
  end
end
