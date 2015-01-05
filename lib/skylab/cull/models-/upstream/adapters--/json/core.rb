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

        def to_entity_stream_stream
          self._IMPLEMENT_ME
        end
      end

  end
end
