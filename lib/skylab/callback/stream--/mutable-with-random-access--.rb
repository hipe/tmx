module Skylab::Callback

  class Stream__

    class Mutable_with_Random_Access__  # abstract base class

      def initialize scan_proc, name_method_i
        @name_method_i = name_method_i
        @scan_p = scan_proc
      end

      def length
        scan = bld_scan
        count = 0
        count += 1 while scan.gets
        count
      end

      def first
        bld_scan.gets
      end

      def has_name name_x
        x = any_item_at_name name_x
        if x
          true
        else
          false
        end
      end

      def [] name_x
        x = any_item_at_name name_x
        if x
          map_aref_value x  # :+#hook-out
        end
      end

      private def any_item_at_name name_x
        scan = bld_scan
        while x = scan.gets
          name_x_ = x.send @name_method_i
          if name_x == name_x_
            result = x
            break
          end
        end
        result
      end

      def get_names
        scan = bld_scan
        y = []
        while x = scan.gets
          y.push x.send @name_method_i
        end
        y
      end

      def each_pair
        if block_given?
          scan = bld_scan
          while x = scan.gets
            yield x.send( @name_method_i ), map_aref_value( x )
          end ; nil
        else
          to_enum :each_pair
        end
      end

      def each
        if block_given?
          scan = bld_scan
          while x = scan.gets
            yield x
          end ; nil
        else
          to_enum
        end
      end

      # ~ mutators

      def []= name_x, x
        scan = bld_scan
        while x_ = scan.gets
          if name_x == x_.send( @name_method_i )
            did_find = true
            found_x = x_
            break
          end
        end
        if did_find
          replace_via_new_mixed_and_old_value_and_name x, found_x, name_x  # :+#hook-out
        else
          add_via_mixed_and_name x, name_x  # :+#hook-out
        end
        x
      end

    private

      def bld_scan
        @scan_p.call
      end
    end
  end
end
