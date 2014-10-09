module Skylab::Callback

  class Scan

    class With_Random_Access__

      def initialize scn, meth_i
        @a = [] ; @h = {}
        @d = -1
        @done = false
        @meth_i = meth_i
        @scn = scn
      end

      def to_a
        @done or flush
        @a.map { |i| @h.fetch i }
      end

      def to_h
        @done or flush
        @h.dup
      end

      def gets
        if ! @done
          at_unknown_index @d + 1
        end
      end

      def get_names
        @done or flush
        @a.dup
      end

      def has_name i
        if @done
          @h.key? i
        elsif @h.key? i
          true
        else
          _x = fetch_when_not_done i, EMPTY_P_
          _x and true
        end
      end

      def at * i_a
        i_a.map( & method( :fetch ) )
      end

      def at_position d
        while ! @done && @d < d
          at_unknown_index @d + 1
        end
        @h.fetch @a.fetch d
      end

      def [] i
        fetch i do end
      end

      def fetch i, &p
        if @done
          @h.fetch i, & p
        elsif x = @h[ i ]
          x
        else
          fetch_when_not_done i, p
        end
      end

      private def fetch_when_not_done i, p
        scn = to_value_scanner
        while x = scn.gets
          if i == x.send( @meth_i )
            break
          end
        end
        if x
          x
        elsif p
          if 1 == p.arity
            p[ i ]
          else
            p[]
          end
        else
          raise ::KeyError, "key not found: #{ i.inspect }"
        end
      end

      def concat_by scn
        to_scan.concat_by( scn ).with_random_access_keyed_to_method @meth_i
      end

      def reduce_by i=nil
        if i
          if block_given?
            scn = to_value_scanner
            ivar = :"@#{ i }"
            while x = scn.gets
              x.instance_variable_defined?( ivar ) and yield x
            end
          else
            enum_for :reduce_by, i
          end
        else
          ::Enumerator.new do |y|
            scn = to_value_scanner
            while x = scn.gets
              _b = yield x
              _b and y << x
            end ; nil
          end
        end
      end

      def group_by & p
        each_value.group_by( & p )
      end

      def each_value
        if block_given?
          scn = to_value_scanner
          while x = scn.gets
            yield x
          end ; nil
        else
          to_enum :each_value
        end
      end

      def to_scanner
        to_value_scanner
      end

      def to_value_scanner
        if @done
          to_scanner_when_done Callback_::Scn
        else
          to_scanner_when_not_done Callback_::Scn
        end
      end

      def to_scan
        if @done
          to_scanner_when_done Scan
        else
          to_scanner_when_not_done Scan
        end
      end

    private

      def to_scanner_when_done cls
        d = -1 ; last = @last
        cls.new do
          if d < last
            @h.fetch @a.fetch d += 1
          end
        end
      end

      def to_scanner_when_not_done cls
        d = -1
        cls.new do
          if @done
            if d < @last
              at_known_index d += 1
            end
          elsif d < @d
            at_known_index d += 1
          else
            at_unknown_index d += 1
          end
        end
      end

      def at_known_index d
        @h.fetch @a.fetch d
      end

      def flush
        while ! @done
          at_unknown_index @d + 1
        end ; nil
      end

      def at_unknown_index d
        while @d < d
          x = @scn.gets
          if x
            @d += 1
            name_i = x.send @meth_i
            did = nil
            @h.fetch name_i do
              did = true
              @h[ name_i ] = x
            end
            did or raise ::KeyError, "won't clobber existing '#{ name_i }'"
            @a.push name_i
          else
            @done = true
            @length = @a.length
            @last = @length - 1
            x = nil
            break
          end
        end
        x
      end
    end
  end
end
