module Skylab::Cull

  module Models_::Upstream

      class FileBasedAdapter_

        class << self

          def via_path path, & oes_p
            new path, & oes_p
          end
        end

        def initialize path, & oes_p
          @path = path
          @_emit = oes_p
        end

        def to_mutable_marshal_box_for_survey survey

          _upstream = "file:#{ survey.maybe_relativize_path__ @path }"

          bx = Common_::Box.new
          bx.add :upstream, _upstream
          bx.add :adapter, adapter_symbol
          bx
        end

        def entity_stream_at_some_table_number d
          estream = nil
          st = to_entity_stream_stream
          count = 0
          d.times do
            estream = st.gets
            estream or break
            count += 1
          end
          if estream
            estream
          else
            @_emit.call :error, :early_end_of_stream do
              event_for_fell_short_of_count d, count
            end
            UNABLE_
          end
        end
      end

  end
end
