module Skylab::Brazen

  class CLI

    # ~ #comport:face this whole file. (just to fit in 'tmx')

    module Client
      module Adapter
        module For
          module Face
            module Of
              module Hot
                def self.[] kernel, token
                  Client__
                end
              end
            end
          end
        end
      end
    end

    class Client__

      def self.call kernel, token
        a = kernel.get_normal_invocation_string_parts ; a.push token
        Client__.new( * kernel.three_streams, a )
      end

      def pre_execute
        self
      end

      def is_autonomous
        true
      end

      def get_autonomous_quad argv
        [ self, :invoke, [ argv ], nil ]  # receiver, method, args, block
      end

      def is_visible
        true
      end

      def get_summary_a_from_sheet sht
      end
    end
  end
end
