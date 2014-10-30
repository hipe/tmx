module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Normalization__

        class Downstream_IO__ < self  # see [#022]:##write

          class << self

            def mixed_via_iambic x_a
              new do
                process_iambic_fully x_a
                clear_all_iambic_ivars
              end.produce_mixed_result
            end
          end

          Entity_.call self do

            o :iambic_writer_method_name_suffix, :'='

            def path=
              @do_execute = true
              @path_arg = Headless_::Lib_::Bsc_[].trio.
                via_value_and_variegated_symbol iambic_property, :path
            end

            o :properties, :is_dry_run, :on_event, :outstream

          end

          def initialize & p
            @is_dry_run = false
            @outstream = nil
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
            @path = @path_arg.value_x
            if @path
              via_path
            elsif @outstream
              @as_normal_value[ @outstream ]
            else
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

          def when_stat

            _ev = build_neutral_event_with :before_editing_existing_file,
                :path, @path, :stat, @stat do |y, o|

              if o.stat.size.zero?
                _zero_note = " empty file"
              end

              y << "updating#{ _zero_note } #{ pth o.path }#{ _zero_note }"
            end

            send_event _ev

            _io = if @is_dry_run
              Headless_::IO.dry_stub_instance
            else
              ::File.open @path, 'r+'
            end

            @as_normal_value[ _io ]
          end

          def when_no_stat

            _ev = build_neutral_event_with :before_probably_creating_new_file,
                :path, @path do |y, o|

              y << "creating #{ pth o.path }"
            end
            send_event _ev

            if @is_dry_run
              @as_normal_value[ Headless_::IO.dry_stub_instance ]
            else
              via_path_open_file
            end
          end

          def via_path_open_file
            _io = ::File.open @path, WRITE_MODE_
            @as_normal_value[ _io ]
          rescue ::SystemCallError => e  # Errno::ENOENT, Errno::ENOENT
            _ev = Event_.wrap.exception e, :path_hack
            @on_event[ _ev ]
          end
        end
      end
    end
  end
end
