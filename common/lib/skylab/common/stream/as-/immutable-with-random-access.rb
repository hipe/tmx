module Skylab::Common

  class Stream

    class As_::Immutable_with_Random_Access

      class << self

        def new_with * x_a
          new do
            init_one_off_via_iambic x_a
          end
        end

        def curry_with * x_a
          new do
            process_iambic_fully x_a
            freeze
          end
        end
      end  # >>

      def build_with * x_a
        otr = dup
        otr.init_copy_via_iambic x_a
        otr
      end

    protected

      def init_copy_via_iambic x_a
        process_iambic_fully x_a
        _receive_upstream @produce_upstream_p.call
        nil
      end

    private

      def initialize * a, & p

        @each_pair_mapper = @value_mapper = nil

        if a.length.nonzero?
          __init_identity_via_args( * a )
        end

        p and instance_exec( & p )
      end

      def init_one_off_via_iambic x_a
        process_iambic_fully x_a ; nil
      end

      def __init_identity_via_args st, key_method_name, x_a=nil

        if st
          _receive_upstream st
        end

        if key_method_name
          @key_method_name = key_method_name
        end

        if x_a and x_a.length.nonzero?
          process_iambic_fully x_a
        end

        NIL_
      end

      def process_iambic_fully x_a
        process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
        nil
      end

      include Home_.lib_.fields::Attributes::Lib::Polymorphic_Processing_Instance_Methods

    private

      def key_method_name=
        @key_method_name = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def each_pair_mapper=
        @each_pair_mapper = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def on_assignment_via_value_and_name=
        @on_assignment_via_value_and_name = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def upstream=  # use for one-offs, not curries
        _receive_upstream gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def upstream_proc=  # use for curries, not one-offs
        @produce_upstream_p = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def value_mapper=  # #ra-105 in [#044]
        @value_mapper = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def _receive_upstream st
        @a = [] ; @h = {}
        @d = -1
        @done = false
        @upstream = st ; nil
      end

    public

      def h_  # READ ONLY ! accomplices only!
        @h
      end

      def to_mutable_box_like_proxy
        to_new_mutable_box_like_proxy
      end

      def to_new_mutable_box_like_proxy
        @done or flush
        Home_::Stream::As_Mutable_Box.new @a.dup, @h.dup
      end

      def length
        @done or flush
        @a.length
      end

      def first
        at_position_if_any 0
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
          _at_unknown_index @d + 1
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
          __has_name_for_unseen_name_when_not_done i
        end
      end

      def at * i_a
        i_a.map( & method( :fetch ) )
      end

      def at_position_if_any d
        _advance_to_position_if_any d
        if d < @a.length
          @h.fetch @a.fetch d
        end
      end

      def at_position d
        _advance_to_position_if_any d
        @h.fetch @a.fetch d
      end

      def index k
        if @h.key? k
          @a.index k
        else
          self._WRITE_ME
        end
      end

      def [] i
        fetch i do end
      end

      def fetch i, & p

        x = @h[ i ]

        if ! ( x || @done )
          x = ___lookup_any_value_for_unseen_name_when_not_done i
        end

        if x
          if @value_mapper
            @value_mapper[ x ]
          else
            x
          end
        elsif p
          if 1 == p.arity
            p[ i ]
          else
            p[]
          end
        else
          raise ::KeyError, __say_name_not_found( i )
        end
      end

      def cached k
        @h.fetch k
      end

      def ___lookup_any_value_for_unseen_name_when_not_done i  # see note #ra-180 in [#044]
        yes = __has_name_for_unseen_name_when_not_done i
        if yes
          @h.fetch i
        end
      end

      def __has_name_for_unseen_name_when_not_done i
        did_have = false
        while true
          x = @upstream.gets
          if ! x
            _become_done
            break
          end
          name_i = x.send @key_method_name
          _store_via_value_and_supposedly_unique_name x, name_i
          if i == name_i
            did_have = true
            break
          end
        end
        did_have
      end

      def __say_name_not_found i
        "key not found: #{ i.inspect }"
      end

      def reduce_by i=nil
        if i
          if block_given?
            st = to_value_stream
            ivar = :"@#{ i }"
            x = st.gets
            while x
              x.instance_variable_defined?( ivar ) and yield x
              x = st.gets
            end
          else
            enum_for :reduce_by, i
          end
        else
          ::Enumerator.new do |y|
            st = to_value_stream
            x = st.gets
            while x
              _b = yield x
              _b and y << x
              x = st.gets
            end ; nil
          end
        end
      end

      def group_by & p
        each_value.group_by( & p )
      end

      def each_value
        if block_given?
          st = to_value_stream
          x = st.gets
          while x
            yield x
            x = st.gets
          end ; nil
        else
          to_enum :each_value
        end
      end

      def each
        if block_given?
          st = to_pair_stream
          pair = st.gets
          while pair
            yield pair.value_x
            pair = st.gets
          end
        else
          to_enum :each
        end
      end

      def each_pair
        if block_given?
          st = to_pair_stream
          pair = st.gets
          if @each_pair_mapper
            while pair
              yield( * @each_pair_mapper[ pair ] )
              pair = st.gets
            end
          else
            while pair
              yield pair.name_symbol, pair.value_x
              pair = st.gets
            end
          end
        else
          to_enum :each_pair
        end
      end

      def each_name & p
        if @done
          @a.each( & p )
        else
          d = -1
          begin
            if d < @d
              yield @a.fetch d += 1
              redo
            end
            x = _at_unknown_index d += 1
            x or break
            yield x.send @key_method_name
            redo
          end while nil
        end
      end

      def to_pair_stream
        _to_name_stream.map_by do | sym |
          Pair.via_value_and_name @h.fetch( sym ), sym
        end
      end

      def to_value_stream
        if @done
          __to_stream_when_done Home_::Stream
        else
          __to_stream_when_not_done Home_::Stream
        end
      end

      # ~ (

      def map_reduce_by & p
        to_stream.map_reduce_by( & p )
      end

      # ~ )

    private

      def _to_name_stream
        if @done
          __to_name_stream_when_done
        else
          __to_name_stream_when_not_done
        end
      end

      def __to_stream_when_done cls
        d = -1 ; last = @last
        cls.new do
          if d < last
            @h.fetch @a.fetch d += 1
          end
        end
      end

      def __to_name_stream_when_done
        d = -1 ; last = @last
        Stream_.new do
          if d < last
            @a.fetch d += 1
          end
        end
      end

      def __to_stream_when_not_done cls
        d = -1
        cls.new do
          if @done
            if d < @last
              _at_known_index d += 1
            end
          elsif d < @d
            _at_known_index d += 1
          else
            _at_unknown_index d += 1
          end
        end
      end

      def __to_name_stream_when_not_done
        d = -1
        Stream_.new do
          if @done
            @a.fetch d += 1
          elsif d < @d
            @a.fetch d += 1
          else
            __key_at_unknown_index d += 1
          end
        end
      end

      def _at_known_index d
        @h.fetch @a.fetch d
      end

      def flush
        while ! @done
          _at_unknown_index @d + 1
        end ; nil
      end

      def __key_at_unknown_index d
        x = _at_unknown_index d
        if x
          x.send @key_method_name
        end
      end

      def _advance_to_position_if_any d
        while ! @done && @d < d
          _at_unknown_index @d + 1
        end ; nil
      end

      def _at_unknown_index d
        while @d < d
          x = @upstream.gets
          if x
            name_i = x.send @key_method_name
            _store_via_value_and_supposedly_unique_name x, name_i
          else
            _become_done
            x = nil
            break
          end
        end
        x
      end

      def _store_via_value_and_supposedly_unique_name x, name_i  # must increment d
        did = nil
        @h.fetch name_i do
          did = true
          @h[ name_i ] = x
        end
        if did
          @d += 1
          @a.push name_i ; nil
        else
          raise ::KeyError, ___say_wont_clobber_name( name_i )
        end
      end

      def ___say_wont_clobber_name name_i
        "won't clobber existing '#{ name_i }'"
      end

      def _become_done
        @done = true
        @length = @a.length
        @last = @length - 1 ; nil
      end
    end
  end
end
