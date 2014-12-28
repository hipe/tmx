module Skylab::Cull

  class Models_::Upstream

      Autoloader_[ ( Adapters__ = ::Module.new ), :boxxy ]  # ~ stowaway

      class Adapters__::JSON < Upstream_::File_Based_Adapter_

        def to_descriptive_event
          build_event_with(
              :json_upstream,
              :path, @path,
              :ok, true ) do | y, o |

            y << "JSON file: #{ pth o.path }"
          end
        end
      end

  end
end
