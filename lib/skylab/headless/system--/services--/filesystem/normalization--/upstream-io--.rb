module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Normalization__

        class Upstream_IO__ < self  # see [#022]

          extend Common_Module_Methods_

          Entity_.call self do

            o :iambic_writer_method_name_suffix, :"="

            def path=
              @do_execute = true
              @path_arg = Headless_::Lib_::Bsc_[].
                trio.via_x_and_i iambic_property, :path ; nil
            end

            def path_arg=  # LOOK a trio, not a value
              @do_execute = true
              @path_arg = iambic_property
              @path_arg_was_explicit = true
            end

            def only_apply_expectation_that_path_is_file=
              @is_only_path_ftype_expectation = true
            end

            o :properties, :instream, :on_event
          end

          def initialize & p
            @do_execute = false
            @instream = nil
            @is_only_path_ftype_expectation = false
            @path_arg_was_explicit = false
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

          def instream_is_noninteractive_and_open
            ! ( @instream.tty? || @instream.closed? )
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
              when_no_stat
            end
          end

          def when_no_stat
            @on_event[ wrap_exception @stat_e ]
          end

          def when_stat
            if FILE_FTYPE_ == @stat.ftype
              when_stat_is_file
            else
              _ev = via_stat_and_path_build_wrong_ftype_event FILE_FTYPE_
              @on_event[ _ev ]
            end
          end

          def when_stat_is_file
            if @is_only_path_ftype_expectation
              @as_normal_value[ ACHIEVED_ ]
            else
              via_path_open_file
            end
          end

          def via_path_open_file
            set_IO_and_e
            if @IO
              @as_normal_value[ @IO ]
            else
              @on_event[ wrap_excetion @e ]
            end
          end

          def set_IO_and_e
            @IO = ::File.open @path, READ_MODE_  # :#open-filehandle-1 - don't loose track
            @e = nil
            nil
          rescue ::SystemCallError => @e  # Errno::EISDIR, Errno::ENOENT etc
            @IO = false
            nil
          end

          def wrap_exception e

            if @path_arg_was_explicit
              _xtra = [ :search_and_replace_hack,
                %r(\bfile or directory\b),
                -> o do
                  par o.path_arg.property
                end ]
            end

            Event_.wrap.exception e, :path_hack, * _xtra,
              :properties, :path_arg, @path_arg

          end
        end
      end
    end
  end
end
