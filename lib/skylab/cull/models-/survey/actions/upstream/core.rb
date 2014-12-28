module Skylab::Cull

  class Models_::Survey

    class Actions::Upstream < Model_

      def initialize srv
        @survey = srv
        super
      end

    private

      def first_edit_shell
        Models_::Upstream::First_Edit.new
      end

      def process_first_edit sh

        ent = Models_::Upstream.edit_entity @kernel, @on_event_selectively do | o |

          o.reference_path @survey.path
          o.shell sh
        end

        ent and begin
          @upstream = ent
          self
        end
      end

    public

      def marshal_dump
        @upstream.marshal_dump_for_survey @survey
      end

      def to_event
        @upstream.to_event
      end
    end
  end
end
