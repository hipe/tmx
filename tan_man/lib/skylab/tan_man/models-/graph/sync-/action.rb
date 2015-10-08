module Skylab::TanMan

  class Models_::Graph

    class Sync_

      class Action < DocEnt_::Action

        # this is an ordinary [br] model action with lots of custom
        # normalization oweing to our experiment with possibly three
        # "waypoints": input, "hereput" and output. see [#026] for
        # more about the architecture of syncing.

        Property = DocEnt_.entity_property_class

        edit_entity_class(

          :preconditions, EMPTY_A_,

          :inflect, :verb, 'sync', :noun, 'graph',

          :flag, :property, :dry_run,

          :reuse, Home_::Model_::Document_Entity.IO_properties,

          :for_direction, :hereput, :property, :hereput_string,
          :for_direction, :hereput, :property, :hereput_path

        )

        def document_entity_normalize_

          # our rules are pretty weird, so we do it manually

          o = DocEnt_::Byte_Stream_Identifier_Resolver.new( @kernel, & handle_event_selectively )

          o.formals formal_properties

          o.for_model model_class

          o.against_argument_box @argument_box

          o.set_custom_direction_mapping :hereput, :input

          # some front clients will always throw in a workspace path
          # (guess) to default in for a missing input or output path, and
          # then when the workspace is not found an error happens. in our
          # case, if a "hereput" is provided, we *never* want to employ the
          # above mechanics, because it gets in the way of what we do below.

          h = @argument_box.h_
          if h[ :hereput_path ] || h[ :hereput_string ] and h[ :workspace_path ]
            @argument_box.remove :workspace_path
          end

          ok, inp, herep, outp = o.solve_at :input, :hereput, :output

          ok &&= receive_byte__input__identifier_ inp

          ok and @byte_herestream_ID = maybe_convert_to_stdin_stream_( herep )

          ok &&= receive_byte__output__identifier_ outp

          ok and begin

            @resolver = o

            __effect_rule_table_validation
          end
        end

        def __effect_rule_table_validation

          # see the spec which expresses the below as a rule table

          in_ID = document_entity_byte_upstream_identifier
          here_ID = @byte_herestream_ID
          out_ID = document_entity_byte_downstream_identifier

          if in_ID
            if here_ID
              if ! out_ID  # case 2
                out_ID = here_ID.to_byte_downstream_identifier
                @_DEBDID = out_ID
              end
            elsif out_ID
              do_build_transient_graph = true  # case 4
            end
          elsif here_ID && out_ID
            only_write_hereput_to_output = true  # case 5
          end

          if ! only_write_hereput_to_output
            miss_a = nil
            in_ID or ( miss_a ||= [] ).push :input
            out_ID or ( miss_a ||= [] ).push :output
          end

          if miss_a
            __missing miss_a
          else
            o = Graph_::Sync_.new in_ID, here_ID, out_ID, to_trio_box_proxy,
              @kernel, & handle_event_selectively

            o.do_build_transient_graph = do_build_transient_graph
            o.only_write_hereput_to_output = only_write_hereput_to_output

            @gsync = o
            ACHIEVED_
          end
        end

        def __missing miss_dir_sym_a
          last_x = nil
          miss_dir_sym_a.each do | sym |
            last_x = @resolver.when_count_is_not_one sym
          end
          last_x
        end

        def produce_result
          _ok = @gsync.flush
          _ok and __persist
        end

        def __persist

          @gsync.the_document_controller.persist_into_byte_downstream_identifier(
            document_entity_byte_downstream_identifier,
            :is_dry, @argument_box[ :dry_run ],
            & handle_event_selectively )
        end
      end
    end
  end
end
