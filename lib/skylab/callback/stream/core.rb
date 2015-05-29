module Skylab::Callback

  class Stream < ::Proc  # see [#044]

    alias_method :gets, :call

    class << self

      def the_empty_stream
        @tes ||= new do end
      end

      def immutable_with_random_access
        Stream_::Immutable_with_Random_Access__
      end

      def mutable_with_random_access
        Stream_::Mutable_with_Random_Access__
      end

      def ordered st
        Stream_::Ordered__[ st ]
      end

      def stream_class
        self
      end

      def via_item x, & p
        p_ = -> do
          p_ = EMPTY_P_
          x
        end
        st = new do
          p_[]
        end
        p and st = st.map_reduce_by( & p )
        st
      end

      def via_nonsparse_array a, & p

        d = -1 ; last = a.length - 1

        st = new do
          if d < last
            a.fetch d += 1
          end
        end

        p and st = st.map_reduce_by( & p )

        st
      end

      def via_times num_times, & p

        d = -1 ; last = num_times - 1

        st = new do
          if d < last
            d += 1
          end
        end

        p and st = st.map_reduce_by( & p )

        st
      end

      def via_range r, & p

        if r.begin < r.end
          amount_to_add = 1
          d = r.begin - amount_to_add
          last = if r.exclude_end?
            r.end - amount_to_add
          else
            r.end
          end
        else
          amount_to_add = -1
          d = r.begin - amount_to_add
          last = if r.exclude_end?
            r.end - amount_to_add
          else
            r.end
          end
        end

        st = new do
          if last != d
            d += amount_to_add
          end
        end

        p and st = st.map_reduce_by( & p )

        st
      end

      def with_random_access
        Stream_::With_Random_Access__
      end

    end  # >>

    def initialize x=nil, & p

      @upstream = x
      super( & p )
    end

    attr_reader :upstream

    # ~ result in boolean

    def length_exceeds d

      does_exceed = false
      known_length = 0
      begin
        if known_length > d
          does_exceed = true
          break
        end
        gets or break
        known_length += 1
        redo
      end while nil
      does_exceed
    end

    # ~ result in number

    def count
      d = 0
      d +=1 while gets
      d
    end

    # ~ result in zero or one item

    def last
      begin
        x = gets
        x or break
        x_ = x
        redo
      end while nil
      x_
    end

    def map_detect & p
      begin
        x = gets
        x or break
        x_ = p[ x ]
        x_ and break
        redo
      end while nil
      x_
    end

    def detect & p
      begin
        x = gets
        x or break
        p[ x ] and break
        redo
      end while nil
      x
    end

    # ~ result in structures of lesser constituency (st's, ary's, bx's)

    def reduce_by & p

      new do
        begin
          x = gets
          x or break
          _ok = p[ x ]
          _ok and break
          redo
        end while nil
        x
      end
    end

    def map_reduce_by & p

      new do
        begin
          x = gets
          x or break
          x_ = p[ x ]
          x_ and break
          redo
        end while nil
        x_
      end
    end

    # `limit_by` has an implementation at [#cb-016]

    def take d, & map_reduce_p

      a = []
      count = 0

      while count < d

        x = gets
        x or break

        if map_reduce_p
          x = map_reduce_p[ x ]
          x or break
        end

        x and a.push x

        count += 1
      end

      a
    end

    # ~ result in structures of same length as constituency (st's, ary's, bx's)

    def each

      if block_given?
        begin
          x = gets
          x or break
          yield x
          redo
        end while nil
        NIL_
      else
        to_enum
      end
    end

    def map_by & p

      new do
        x = gets
        if x
          x = p[ x ]
        end
        x
      end
    end

    def to_a

      a = []
      begin
        x = gets
        x or break
        a.push x
        redo
      end while nil
      a
    end

    def map & p

      a = []
      begin
        x = gets
        x or break
        a.push p[ x ]
        redo
      end while nil
      a
    end

    def flush_to_box_keyed_to_method sym

      bx = Callback_::Box.new
      begin
        x = gets
        x or break
        bx.add x.send( sym ), x
        redo
      end while nil
      bx
    end

    def flush_to_immutable_with_random_access_keyed_to_method i, * x_a

      Stream_::Immutable_with_Random_Access__.new self, i, x_a
    end

    def flush_to_mutable_box_like_proxy_keyed_to_method sym

      Stream_::Mutable_Box_Like_Proxy.via_flushable_stream__ self, sym
    end

    def flush_to_polymorphic_stream

      Stream_::Polymorphic___.new self
    end

    # ~ result in structures of greater constitency

    def unshift_by * x_a

      st = Stream_.via_nonsparse_array x_a

      p = -> do
        x = st.gets
        if x
          x
        else
          p = method :gets
          p[]
        end
      end

      new do
        p[]
      end
    end

    def push_by * x_a

      concat_by Stream_.via_nonsparse_array x_a
    end

    def concat_by st_

      st = self
      p = -> do
        x = st.gets
        x or begin
          p = -> do
            st_.gets
          end
          p[]
        end
      end

      new do
        p[]
      end
    end

    def expand_by & lower_st_p

      proc_via_lower_stream = nil
      st = self

      p = upper_p = -> do
        begin
          upper_x = st.gets
          if upper_x
            lower_st = lower_st_p[ upper_x ]
            if lower_st
              x = lower_st.gets
              if x
                p = proc_via_lower_stream[ lower_st ]
                break
              else
                redo
              end
            else
              # you can reduce as well as expand
              redo
            end
          else
            p = EMPTY_P_
            x = upper_x
            break
          end
        end while nil
        x
      end

      proc_via_lower_stream = -> lower_st do
        -> do
          x = lower_st.gets
          x or begin
            p = upper_p
            p[]
          end
        end
      end

      new do
        p[]
      end
    end

    private def new & p
      self.class.new @upstream, & p
    end

    class Release_Resource_Proxy < ::Proc

      alias_method :release_resource, :call
    end

    Stream_ = self
  end
end
