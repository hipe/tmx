module Skylab::Cull

  class Models_::Upstream

      class Adapters__::Markdown < Upstream_::File_Based_Adapter_

        def to_descriptive_event
          build_event_with(
              :markdown_upstream,
              :path, @path,
              :ok, true ) do | y, o |

            y << "markdown file: #{ pth o.path }"
          end
        end
      end

  end
end
