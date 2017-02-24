module Skylab::Treemap

  class Models_::Tree

    module Actions

      class Ping < Model_.common_action_class

        @is_promoted = true

        def produce_result

          maybe_send_event :info, :ping do

            Common_::Event.inline_neutral_with :ping do | y, o |
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
          :property, :downstream_reference,

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
          :property, :upstream_reference,

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

          _col = Home_.lib_.basic::Module::As::Collection[ Output_Adapters_ ]

          oa = Home_.lib_.brazen::Collection::Common_fuzzy_retrieve[
            qualified_knownness( :output_adapter ),
            _col.method( :to_entity_stream ),
            & handle_event_selectively ]

          if oa
            @_unbound_output_adapter = oa
            ACHIEVED_
          else
            oa
          end
        end

        def __resolve_waypoints

          @_n11n = Home_.lib_.system.filesystem( :Path_Based ).new_with(
            :recognize_common_string_patterns, & handle_event_selectively )

          ok = __resolve_up
          ok &&= __resolve_thru
          ok && __resolve_down
        end

        def __resolve_up

          _resolve_waypoint(
            :@upstream_ID,
            qualified_knownness( :upstream_reference ),
            :up, :stdin )
        end

        def __resolve_thru

          # this is the one field that is not [effectively] required

          if @argument_box[ :throughstream_identifier ]

            _resolve_waypoint(
              :@throughstream_ID,
              qualified_knownness( :throughstream_identifier ),
              :down, :stderr )
          else
            @throughstream_ID = nil
            ACHIEVED_
          end
        end

        def __resolve_down

          _resolve_waypoint(
            :@downstream_ID,
            qualified_knownness( :downstream_reference ),
            :down, :stdout )
        end

        def _resolve_waypoint destination_ivar, qualified_knownness, up_down, dash_means_sym

          h = @argument_box.h_

          _standards = case up_down

          when :down
            [ :stderr, h.fetch( :stderr ),
              :stdout, h.fetch( :stdout ) ]

          when :up
            [ :stdin, h.fetch( :stdin ) ]
          end

          kn = @_n11n.call_via(
            :up_or_down, up_down,
            * _standards,
            :qualified_knownness_of_path, qualified_knownness,
            :dash_means, dash_means_sym,
          )

          if kn

            _ID = @_n11n.byte_whichstream_identifier_for kn.value_x, up_down

            instance_variable_set destination_ivar, _ID

            ACHIEVED_
          else
            kn
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
            Common_::Name.via_variegated_symbol( sym ).as_const, false )

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
