module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Normalization__

        class Upstream_IO__ < self  # see [#022]

          class << self

            def mixed_via_iambic x_a
              new do
                process_iambic_fully x_a
                clear_all_iambic_ivars
              end.produce_mixed_result
            end
          end

          Entity_[ self, -> do

            o :iambic_writer_method_name_suffix, :"="

            def path_arg=  # LOOK at trio, not a value
              @do_execute = true
              @path_arg = iambic_property
            end

            o :properties, :instream, :on_event
          end ]

          Event_.sender self

          def initialize & p
            @clobber_is_OK = true   # always true for now
            @do_execute = false
            @instream = nil
            instance_exec( & p )
            @as_normal_value ||= IDENTITY_
          end

          def produce_mixed_result
            if @do_execute
              execute  # is an inline normalization
            else
              freeze  # is a curried normalization (not implemented yet)
            end
          end

        private

          def execute
            if @instream
              when_formal_both
            else
              when_formal_path
            end
          end

          def when_formal_both
            if @path_arg.actuals_has_name
              if instream_is_noninteractive_and_open
                when_actual_both
              else
                when_actual_path
              end
            elsif instream_is_noninteractive_and_open
              when_actual_instream
            else
              when_actual_neither
            end
          end

          def when_formal_path
            if @path_arg.actuals_has_name
              when_actual_path
            else
              when_path_not_provided
            end
          end

          def when_actual_both  # #storypoint-20
            _ev = build_not_OK_event_with :ambiguous_upstream_arguments,
                :path_arg, @path_arg do |y, o|

              _prop = o.path_arg.property

              y << "ambiguous upstream arguments - cannot read from both #{
                }STDIN and #{ par _prop }"
            end
            send_event _ev
          end

          def when_actual_neither
            _ev = build_not_OK_event_with :missing_required_properties,
                :path_property, @path_arg.property do |y, o|
              y << "expecting #{ par o.path_property } or STDIN"
            end
            send_event _ev
          end

          def when_path_not_provided
            _ev = build_not_OK_event_with :missing_required_properties,
                :path_property, @path_arg.property do |y, o|
              y << "expecting #{ par o.path_property }"
            end
            send_event _ev
          end

          def when_actual_instream
            @as_normal_value[ @instream ]
          end

          def when_actual_path
            @path = @path_arg.value_x
            path_exists_and_set_stat_and_stat_error @path
            if @stat
              when_stat
            else
              _ev = Event_.wrap.exception @stat_e, :path_hack
              @on_event[ _ev ]
            end
          end

          def when_stat
            if FILE_FTYPE_ == @stat.ftype
              via_path_open_file
            else
              _ev = via_stat_and_path_build_wrong_ftype_event FILE_FTYPE_
              @on_event[ _ev ]
            end
          end

          def via_path_open_file
            _io = ::File.open @path, READ_MODE_
            @as_normal_value[ _io ]  # :#open-filehandle-1 - don't loose track
          rescue ::SystemCallError => e  # Errno::EISDIR, Errno::ENOENT etc
            _ev = Event_.wrap.exception e, :path_hack
            @on_event[ _ev ]
          end

          def instream_is_noninteractive_and_open
            ! ( @instream.tty? || @instream.closed? )
          end

          def send_event ev
            @on_event[ ev ]
          end
        end
      end
    end
  end
end
