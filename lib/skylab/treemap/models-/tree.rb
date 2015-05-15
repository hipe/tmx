module Skylab::Treemap

  class Models_::Tree

    module Actions

      class Ping < Model_.common_action_class

        @is_promoted = true

        def produce_result
          maybe_send_event :info, :ping do
            build_neutral_event_with :ping do | y, o |
              y << "hello from #{ app_name }."
            end
          end
          :hello_from_treemap
        end
      end

      class Session < Model_.common_action_class

        @is_promoted = true

        edit_entity_class(

          :required,
          :description, -> y do
            y << "(output) e.g a path on the filesystem. default: STDOUT"
          end,
          :default_proc, -> do
            '-'  # excercize it
          end,
          :property, :downstream_identifier,

          :description, -> y do
            y << "echo each line of input to this waypoint (debugging)"
            y << "e.g a path on the filesystem,"
            y << "'-' for STDERR, '>1' (the string) for STDOUT"
          end,
          :property, :throughstream_identifier,

          :required,
          :description, -> y do
            y << "(input) default: STDIN"
            y << "e.g a path on the filesystem, '-' for STDIN"
          end,
          :default_proc, -> do
            '-'  # excercize it
          end,
          :property, :upstream_identifier,

          :required, :property, :stdin,
          :required, :property, :stdout,
          :required, :property, :stderr,

          :required, :property, :output_adapter
        )

        def produce_result

          ok = __resolve_output_adapter
          ok &&= __resolve_waypoints
          ok && __via_waypoints_and_output_adapter
        end

        def __resolve_output_adapter

          lib = Tr_.lib_.brazen

          oa = lib::Collection::Common_fuzzy_retrieve[
            trio( :output_adapter ),
            lib::Collection_Adapters::Module_as_Collection[ Output_Adapters_ ],
            & handle_event_selectively ]

          if oa
            @_unbound_output_adapter = oa
            ACHIEVED_
          else
            oa
          end
        end

        def __resolve_waypoints

          h = @argument_box.h_

          _ = Tr_.lib_.system.filesystem.normalization

          @_no = _.new_with(
            :stdin, h.fetch( :stdin ),
            :stdout, h.fetch( :stdout ),
            :stderr, h.fetch( :stderr ),
            :recognize_common_string_patterns,
            :result_in_IO_stream_identifier_trio,
            & handle_event_selectively )

          ok = __resolve_up
          ok &&= __resolve_thru
          ok && __resolve_down
        end

        def __resolve_up

          _resolve_waypoint(
            :@upstream_ID,
            trio( :upstream_identifier ),
            :up, :stdin )
        end

        def __resolve_thru

          # this is the one field that is not [effectively] required

          if @argument_box[ :throughstream_identifier ]

            _resolve_waypoint(
              :@throughstream_ID,
              trio( :throughstream_identifier ),
              :down, :stderr )
          else
            @throughstream_ID = nil
            ACHIEVED_
          end
        end

        def __resolve_down

          _resolve_waypoint(
            :@downstream_ID,
            trio( :downstream_identifier ),
            :down, :stdout )
        end

        def _resolve_waypoint destination_ivar, trio, up_down, dash_means_sym

          pair = @_no.call(
            :up_or_down, up_down,
            :path_arg, trio,
            :dash_means, dash_means_sym )

          if pair
            instance_variable_set destination_ivar, pair.value_x
            ACHIEVED_
          else
            pair
          end
        end

        def __via_waypoints_and_output_adapter

          oa = @_unbound_output_adapter.module.new(
            self, & handle_event_selectively )

          sym = oa.required_stream
          st = _build_upstream sym

          if st
            oa.send :"#{ sym }=", st
            @_delegate = oa
            oa.execute
          else
            st
          end
        end

        def stdout_
          @argument_box.fetch :stdout
        end

        def stderr_
          @argument_box.fetch :stderr
        end

        def _build_upstream sym

          x = Input_Adapters_.const_get(
            Callback_::Name.via_variegated_symbol( sym ).as_const, false )

          sym_ = x.required_stream

          st = if :raw_line_upstream == sym_

            __produce_raw_line_upstream
          else

            _build_upstream sym_
          end

          if st
            x.call st do | * i_a, & ev_p |
              @_delegate.maybe_receive_event_on_channel i_a, & ev_p
            end
          else
            st
          end
        end

        def __produce_raw_line_upstream

          if @upstream_ID.lockable_resource.tty?
            @argument_box[ :stderr ].puts "(entering interactive mode)"
          end

          st = @upstream_ID.to_simple_line_stream

          if @throughstream_ID

            st = Input_Adapters_::Build_throughstream_mapper[
              @throughstream_ID.to_minimal_yielder,
              st ]
          end

          st
        end
      end
    end
  end
end
