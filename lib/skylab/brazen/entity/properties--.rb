module Skylab::Brazen

  module Entity

    class Properties__

      def initialize proprietor
        @proprietor = proprietor
      end

      def to_values_array
        scn = to_values_scanner ; a = [] ; x = nil
        a.push x while (( x = scn.gets ))
        a
      end

      def to_values_scanner
        scn = @proprietor.property_method_names.to_values_scanner
        Callback_::Scn.new do
          if (( m_i = scn.gets ))
            @proprietor.send m_i
          end
        end
      end
    end

    class Box__
      def to_values_scanner
        d = -1 ; last = @a.length - 1
        Callback_::Scn.new do
          if d < last
            @h.fetch @a.fetch d += 1
          end
        end
      end
    end
  end
end
