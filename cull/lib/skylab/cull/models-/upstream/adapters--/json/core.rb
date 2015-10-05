module Skylab::Cull

  class Models_::Upstream

      Autoloader_[ ( Adapters__ = ::Module.new ), :boxxy ]  # ~ stowaway

      class Adapters__::JSON < Upstream_::File_Based_Adapter_

        EXTENSIONS = %w( .json )

        def adapter_symbol
          :json
        end

        def to_descriptive_event
          build_event_with(
              :json_upstream,
              :path, @path,
              :ok, true ) do | y, o |

            y << "JSON file: #{ pth o.path }"
          end
        end

        def to_entity_stream_stream  # #todo covered visually by upstream map
          p = -> do
            x = to_entity_stream
            p = EMPTY_P_
            x
          end

          Callback_.stream do
            p[]
          end
        end

        def to_entity_stream
          fh = ::File.open @path, 'r'  # READ_MODE_
          if FIRST_LINE_LOOKS_LINE_STREAMING__ == fh.gets
            JSON_::Streamers__::Structured_progressive[ fh, & @on_event_selectively ]
          else
            fh.rewind
            self._DO_ME
          end
        end

        FIRST_LINE_LOOKS_LINE_STREAMING__ = "[\n"


      private

        def event_for_fell_short_of_count wanted_number, had_number

          build_not_OK_event_with :early_end_of_stream,
              :stream_identifier, Home_.lib_.basic::Pathname.identifier.new( @path ),
              :wanted_number, wanted_number,
              :had_number, had_number do | y, o |

            want = o.wanted_number
            had = o.had_number

            y << "JSON files are always exactly one entity collection #{
             }(\"table\") - table #{ ick want } was requested, #{
              }but had#{ ' only' if had.nonzero? } #{ had } table#{ s had } in #{
               }#{ o.stream_identifier.description_under self }."
          end
        end

        JSON_ = self
      end

  end
end
