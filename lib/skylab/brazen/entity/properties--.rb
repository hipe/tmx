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

      def fetch i, &p
        found = true
        m_i = @reader.property_method_nms_for_rd.fetch i do
          found = false
        end
        found or raise ::KeyError, "key not found: #{ i.inspect }"
        @reader.send m_i
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

      def group_by & p
        each_value.group_by( & p )
      end

      def each_value
        if block_given?
          scn = to_value_scanner ; x = nil
          yield x while x = scn.gets ; nil
        else
          enum_for :each_value
        end
      end

      def to_scanner
        to_value_scanner
      end

      def to_value_scanner
        scn = @reader.property_method_nms_for_rd.to_value_scanner
        Entity.scan.new do
          if (( m_i = scn.gets ))
            @reader.send m_i
          end
        end
      end
    end
  end
end
