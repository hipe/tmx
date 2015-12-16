module Skylab::TestSupport

  module DocTest

    # this new guy, it's gotta be light and generated

    class CLI < Brazen_::CLI

      # ~ universal action adapter customization

      class Action_Adapter < self::Action_Adapter

        MUTATE_THESE_PROPERTIES = [ :downstream ]

        def mutate__downstream__properties
          remove_property_from_front :downstream
        end
      end

      # ~ specific action customization

      Actions = ::Module.new

      # ->

        class Actions::Generate < Action_Adapter

          # here is one way to hack modality-specific defaults ( WILL DEPERECATE see :+[#br-042]

          MUTATE_THESE_PROPERTIES = [
            :arbitrary_proc_array,
            :line_downstream,
          ]

          def mutate__arbitrary_proc_array__properties
            remove_property_from_front :arbitrary_proc_array
            NIL_
          end

          def mutate__line_downstream__properties
            remove_property_from_front :line_downstream
            NIL_
          end

          def prepare_to_parse_parameters  # #hook-in to [br]
            super
            @mutable_backbound_iambic.push(
              :output_adapter, :quickie,
              :line_downstream, @resources.sout )
                # hidden property, can't be overwritten except
                # effectively so with the --output-path option
            NIL_
          end

          # ~ experiment

          def optparse_behavior_for_property prop  # #hook-in: [br]

            # we do not push the token onto the output iambic  # #todo do we ever need to?

            if :help == prop.name_symbol
              -> _ do
                touch_argument_metadata :help
                NIL_
              end
            else
              super
            end
          end

          def bound_call_for_help_request

            # hack an experiment where we re-build the option parser before
            # we use it to render a help screen, only in those cases where
            # the output adapter was indicated explicitly in the ARGV buffer
            # alongside the --help flag

            if @seen[ :output_adapter ]

              _ok = @bound.receive_polymorphic_stream_(
                Callback_::Polymorphic_Stream.via_array( @mutable_backbound_iambic ) )

              # if the above changes our output adapter
              # it may change our formal properties

              if _ok
                @properties = @bound.formal_properties
                init_categorized_properties  # just does it all again!
                super
              else

                # e.g the name of the output adapter was bad. show help anyway

                super
              end
            else
              super
            end
          end
        end

        Action_Adapter_Event_Handling_Customizations__ = ::Module.new  # re-opened below

        class Actions::Intermediates < Action_Adapter

          include Action_Adapter_Event_Handling_Customizations__

          def writing ev
            render_event_as_first_in_multipart_line ev
          end

          def wrote ev
            send_non_payload_event_lines render_event_lines ev
            ACHIEVED_  # don't stop the batch job
          end

          def prepare_backstream_call x_a  # :+[#br-078], [#br-042]

            if :path == x_a[ -2 ]
              path = x_a.last
              if FILE_SEP_ != path[ 0 ]
                path = ::File.expand_path path
                x_a[ -1 ] = path
              end
            end

            super
          end
        end

        class Actions::Recursive < Action_Adapter

          # do not put a trailing newline on these ones - they
          # are first of a pair and "look better" in one line.
          # this behavior will probably become [#br-021] magic

          include Action_Adapter_Event_Handling_Customizations__

          def current_output_path ev, i_a
            receive_event_on_channel ev, i_a
          end

          def before_editing_existing_file ev
            @_saw_first_part = true
            render_event_as_first_in_multipart_line ev
          end

          def before_probably_creating_new_file ev
            @_saw_first_part = true
            render_event_as_first_in_multipart_line ev
          end

          def wrote ev, i_a

            _unreliable = if _saw_first_part

              receive_event_on_channel ev, i_a

            else

              s_a = render_event_lines ev
              s = s_a.first
              s.strip!
              s_a[ 0 ] = "(preview for one file #{ s })"
              send_non_payload_event_lines s_a
            end

            ACHIEVED_  # don't stop the batch job
          end

          attr_reader :_saw_first_part
        end

        # <-

      module Action_Adapter_Event_Handling_Customizations__

        # #hook-in to [br] in two places, one to route events
        # customly, and one to express them customly

      private

        def handle_event_selectively  # #hook-in [br]

          default_p = super

          -> * i_a, & ev_p do

            m = i_a.fetch 1

            if respond_to? m

              if 1 == method( m ).arity
                send m, ev_p[]
              else
                send m, ev_p[], i_a
              end
            else
              default_p[ * i_a, & ev_p ]
            end
          end
        end

        def render_event_as_first_in_multipart_line ev
          s_a = render_event_lines ev
          send_non_payload_event_lines s_a[ 0 .. -2 ]
          @parent.stderr.write "#{ s_a.last } .."
          nil
        end
      end
    end
  end
end
