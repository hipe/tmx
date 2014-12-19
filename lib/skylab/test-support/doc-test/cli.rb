module Skylab::TestSupport

  module DocTest

    # this new guy, it's gotta be light and generated

    class CLI < TestSupport_::Lib_::Bzn_[]::CLI

      class << self

        def new * a
          new_top_invocation a, DocTest_
        end
      end

      def expression_agent_class
        CLI_LIB_.expression_agent_class
      end

      CLI_LIB_ = superclass

      # ~ specific action customization

      module Actions

        class Generate < CLI_LIB_::Action_Adapter

          # here is one way to hack modality-specific defaults

          def prepare_to_parse_parameters  # #hook-in to [br]
            super
            @output_iambic.push(
              :output_adapter, :quickie,
              :line_downstream, @resources.sout )
                # hidden property, can't be overwritten except
                # effectively so with the --output-path option
          end
        end

        class Recursive < CLI_LIB_::Action_Adapter

          # do not put a trailing newline on these ones - they
          # are first of a pair and "look better" in one line.
          # this behavior will probably become [#ba-021] magic

          def build_handle_event_selectively
            default_p = super
            -> * i_a, & ev_p do
              m_i = i_a.fetch 1
              if respond_to? m_i
                send m_i, ev_p[]
              else
                default_p[ * i_a, & ev_p ]
              end
            end
          end

          def before_editing_existing_file ev
            render_event_as_first_in_multipart_line ev
          end

          def before_probably_creating_new_file ev
            render_event_as_first_in_multipart_line ev
          end

        private

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
end
