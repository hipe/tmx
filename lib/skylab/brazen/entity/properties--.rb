module Skylab::Brazen

  module Entity

    class Properties__

      def initialize reader
        @reader = reader
      end

      def [] i
        m_i = @reader.property_method_nms_for_rd[ i ]
        m_i and @reader.send m_i
      end

      def reduce_by i=nil
        if i
          if block_given?
            scn = to_value_scanner
            ivar = :"@#{ i }"
            while (( x = scn.gets ))
              x.instance_variable_defined?( ivar ) and yield x
            end
          else
            enum_for :reduce_by, i
          end
        else
          ::Enumerator.new do |y|
            scn = to_value_scanner
            while (( x = scn.gets ))
              yield( x ) and y << x
            end ; nil
          end
        end
      end

      def to_value_array
        scn = to_value_scanner ; a = [] ; x = nil
        a.push x while (( x = scn.gets ))
        a
      end

      def group_by & p
        to_value_enum.group_by( & p )
      end

      def to_value_enum
        ::Enumerator.new do |y|
          scn = to_value_scanner ; x = nil
          y << x while x = scn.gets ; nil
        end
      end

      def to_value_scanner
        scn = @reader.property_method_nms_for_rd.to_value_scanner
        Callback_::Scn.new do
          if (( m_i = scn.gets ))
            @reader.send m_i
          end
        end
      end
    end

    class Box_
      def get_names
        @a.dup
      end
      def to_value_scanner
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
