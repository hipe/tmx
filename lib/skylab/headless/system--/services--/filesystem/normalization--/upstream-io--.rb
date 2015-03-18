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
              @path_arg = Callback_::Trio.via_x_and_i iambic_property, :path
              ACHIEVED_
            end

            def pathname=
              @do_execute = true
              @path_arg = Callback_::Trio.via_x_and_i iambic_property, :path
              @value_is_pathname = true
              ACHIEVED_
            end

            def path_arg=  # LOOK a trio, not a value
              @do_execute = true
              @path_arg = iambic_property
              @path_arg_was_explicit = true
              ACHIEVED_
            end

            def only_apply_expectation_that_path_is_ftype_of=
              @only_apply_ftype_expectation = true
              @expected_ftype = iambic_property
              ACHIEVED_
            end

            o :properties,
                :as_normal_value,
                :instream,
                :stat
          end

          def initialize & edit_p
            @do_execute = false
            @instream = nil
            @only_apply_ftype_expectation = false
            @path_arg_was_explicit = false
            @value_is_pathname = false
            instance_exec( & edit_p )
            @as_normal_value ||= IDENTITY_
          end

          def produce_mixed_result
            if @do_execute
              execute  # is an inline normalization
            else
              freeze  # is a curried normalization (not implemented yet)
            end
          end

          def execute
            if @instream
              when_formal_both
            else
              when_formal_path
            end
          end

          def when_formal_both
            if @path_arg.is_known_known
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
            if @path_arg.is_known_known
              when_actual_path
            else
              when_path_not_provided
            end
          end

          def when_actual_both  # #storypoint-20
            maybe_send_event :error, :ambiguous_upstream_arguments do
              bld_AUA_event
            end
          end

          def bld_AUA_event
            build_not_OK_event_with :ambiguous_upstream_arguments,
                :path_arg, @path_arg do |y, o|

              _prop = o.path_arg.property

              y << "ambiguous upstream arguments - cannot read from both #{
                }STDIN and #{ par _prop }"
            end
          end

          def when_actual_neither
            maybe_send_event :error, :missing_required_properties do
              bld_MRP_no_path_or_STDIN
            end
          end

          def bld_MRP_no_path_or_STDIN
            build_not_OK_event_with :missing_required_properties,
                :path_property, @path_arg.property do |y, o|
              y << "expecting #{ par o.path_property } or STDIN"
            end
          end

          def when_path_not_provided
            maybe_send_event :error, :missing_required_properties do
              bld_MRP_no_path
            end
          end

          def bld_MRP_no_path
            build_not_OK_event_with :missing_required_properties,
                :path_property, @path_arg.property do |y, o|
              y << "expecting #{ par o.path_property }"
            end
          end

          def when_actual_instream
            @as_normal_value[ @instream ]
          end

          def when_actual_path

            if @value_is_pathname
              pn = @path_arg.value_x
              pathname_exists_and_set_stat_and_stat_error pn
              @path = pn.to_path
            else
              @path = @path_arg.value_x
              path_exists_and_set_stat_and_stat_error @path
            end

            if @stat
              via_stat_execute
            else
              when_no_stat
            end
          end

          def when_no_stat
            maybe_send_event :error, :stat_error do
              wrap_exception @stat_e
            end
          end

          def via_stat_execute
            if @only_apply_ftype_expectation
              via_stat_and_expected_ftype_exert_expectation
            elsif FILE_FTYPE == @stat.ftype
              via_path_open_file
            else
              maybe_send_event :error, :wrong_ftype do
                build_wrong_ftype_event_ @path_arg.value_x, @stat, FILE_FTYPE
              end
            end
          end

          def via_stat_and_expected_ftype_exert_expectation
            if @expected_ftype == @stat.ftype
              @as_normal_value[ ACHIEVED_ ]
            else
              maybe_send_event :error, :wrong_ftype do
                build_wrong_ftype_event_ @path_arg.value_x, @stat, @expected_ftype
              end
            end
          end

          def via_path_open_file
            set_IO_and_e
            if @IO
              @as_normal_value[ @IO ]
            else
              maybe_send_event :error, :exception do
                wrap_excetion @e
              end
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
