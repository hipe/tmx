module Skylab::TestSupport

  module DocTest

    # this new guy, it's gotta be light and generated

    class CLI < Brazen_::CLI

      class << self

        def new * a
          new_top_invocation a, DocTest_.application_kernel_
        end
      end

      def expression_agent_class
        CLI_LIB_.expression_agent_class
      end

      CLI_LIB_ = superclass

      # ~ specific action customization

      Experimental_Hax__ = ::Module.new  # below

      module Actions

        class Generate < CLI_LIB_::Action_Adapter

          # here is one way to hack modality-specific defaults ( WILL DEPERECATE see :+[#br-042]

          def prepare_to_parse_parameters  # #hook-in to [br]
            super
            @mutable_backbound_iambic.push(
              :output_adapter, :quickie,
              :line_downstream, @resources.sout )
                # hidden property, can't be overwritten except
                # effectively so with the --output-path option
          end

          # ~ experiment

          def optparse_behavior_for_property prop  # #hook-in: [br]

            # we do not push the token onto the output iambic  # #todo do we ever need to?

            if :help == prop.name_symbol
              -> _ do
                @seen_h[ :help ] = true  # important
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

            if @seen_h[ :output_adapter ]

              _ok = @bound.receive_polymorphic_stream_(
                Callback_::Polymorphic_Stream_via_Array_.new 0, @mutable_backbound_iambic )

              # if the above changes our output adapter
              # it may change our formal properties

              if _ok
                @properties = @bound.formal_properties
                resolve_categorized_properties  # just does it all again!
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

        class Intermediates < CLI_LIB_::Action_Adapter

          include Experimental_Hax__

          def writing ev
            render_event_as_first_in_multipart_line ev
          end

          def wrote ev
            send_non_payload_event_lines render_event_lines ev
            ACHIEVED_  # don't stop the batch job
          end

          def via_bound_action_mutate_mutable_backbound_iambic x_a  # EEEW :+[#br-078], but maybe see [#br-042]

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

        class Recursive < CLI_LIB_::Action_Adapter

          # do not put a trailing newline on these ones - they
          # are first of a pair and "look better" in one line.
          # this behavior will probably become [#ba-021] magic

          include Experimental_Hax__

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

            if _saw_first_part
              receive_event_on_channel ev, i_a
              true  # don't stop the batch
            else
              s_a = render_event_lines ev
              s = s_a.first
              s.strip!
              s_a[ 0 ] = "(preview for one file #{ s })"
              send_non_payload_event_lines s_a
              true  # don't stop the batch
            end
          end

          attr_reader :_saw_first_part
        end

      end

      module Experimental_Hax__
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
