module Skylab::Cull

  module Models_::Upstream

      class Adapters__::JSON < Here_::FileBasedAdapter_

        EXTENSIONS = %w( .json )

        def adapter_symbol
          :json
        end

        def to_descriptive_event  # (or `to_event`)

          me = self
          Build_event_.call(
            :json_upstream,
            :path, @path,
            :ok, true
          ) do |y, _o|
            y << me.describe_entity_under_( self )
          end
        end

        def describe_entity_under_ expag
          path = @path
          expag.calculate do
            "JSON file: #{ pth path }"
          end
        end

        def to_entity_stream_stream  # #todo covered visually by upstream map
          p = -> do
            x = to_entity_stream
            p = EMPTY_P_
            x
          end

          Common_.stream do
            p[]
          end
        end

        def to_entity_stream
          fh = ::File.open @path, 'r'  # READ_MODE_
          if FIRST_LINE_LOOKS_LINE_STREAMING__ == fh.gets
            JSON_::Streamers__::Structured_progressive[ fh, & @_emit ]
          else
            fh.rewind
            self._DO_ME
          end
        end

        FIRST_LINE_LOOKS_LINE_STREAMING__ = "[\n"


      private

        def event_for_fell_short_of_count wanted_number, had_number

          _BSR = Home_.lib_.basic::Pathname::ByteStreamReference.new @path

          Build_not_OK_event_.call(
            :early_end_of_stream,
            :byte_stream_reference, _BSR,
            :wanted_number, wanted_number,
            :had_number, had_number,
          ) do |y, o|

            want = o.wanted_number
            had = o.had_number

            y << "JSON files are always exactly one entity collection #{
             }(\"table\") - table #{ ick want } was requested, #{
              }but had#{ ' only' if had.nonzero? } #{ had } table#{ s had } in #{
               }#{ o.byte_stream_reference.description_under self }."
          end
        end

        JSON_ = self
      end

  end
end
