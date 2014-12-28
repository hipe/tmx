module Skylab::Cull

  class Models_::Upstream

      class File_Based_Adapter_

        class << self

          def via_path path, & oes_p
            new path, & oes_p
          end
        end

        def initialize path, & oes_p
          @path = path
          @on_event_selectively = oes_p
        end

        include Simple_Selective_Sender_Methods_

        def marshal_dump_for_survey_ survey

          "file:#{ survey.maybe_relativize_path @path }"
        end
      end

  end
end
