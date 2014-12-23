module Skylab::Callback

  class Scan

    class Immutable_with_Random_Access__

      class << self

        def build_with * x_a
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
      end

      def build_with * x_a
        otr = dup
        otr.init_copy_via_iambic x_a
        otr
      end
    protected
      def init_copy_via_iambic x_a
        process_iambic_fully x_a
        _scn = @produce_scan_p.call
        init_scn _scn
        nil
      end
    private

      def initialize * a, & p
        @each_mapper = @each_pair_mapper = @value_mapper = nil
        if a.length.nonzero?
          init_identity_via_args a
        end
        p and instance_exec( & p )
      end

      def init_one_off_via_iambic x_a
        process_iambic_fully x_a ; nil
      end

      def init_identity_via_args a
        scn, meth_i, x_a  = a
        scn and init_scn scn
        meth_i and @meth_i = meth_i
        x_a.length.nonzero? and process_iambic_fully x_a
        nil
      end

      def process_iambic_fully x_a
        process_iambic_stream_fully iambic_stream_via_iambic_array x_a
        nil
      end

      include Callback_::Actor.methodic_lib.iambic_processing_instance_methods

      def init_scn scn
        @a = [] ; @h = {}
        @d = -1
        @done = false
        @scn = scn ; nil
      end

    private

      def key_method_name=
        @meth_i = iambic_property
        KEEP_PARSING_
      end

      def each_mapper=
        @each_mapper = iambic_property
        KEEP_PARSING_
      end

      def each_pair_mapper=
        @each_pair_mapper = iambic_property
        KEEP_PARSING_
      end

      def scan_proc=
        @produce_scan_p = iambic_property
        KEEP_PARSING_
      end

      def scn=
        init_scn iambic_property
        KEEP_PARSING_
      end

      def on_assignment_via_value_and_name=
        @on_assignment_via_value_and_name = iambic_property
        KEEP_PARSING_
      end

      def value_mapper=  # #ra-105 in [#044]
        @value_mapper = iambic_property
        KEEP_PARSING_
      end

    public

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
          has_name_for_unseen_name_when_not_done i
        end
      end

      def at * i_a
        i_a.map( & method( :fetch ) )
      end

      def at_position_if_any d
        advance_to_position_if_any d
        if d < @a.length
          @h.fetch @a.fetch d
        end
      end

      def at_position d
        advance_to_position_if_any d
        @h.fetch @a.fetch d
      end

      def [] i
        fetch i do end
      end

      def fetch i, & p
        x = lookup i
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
          raise ::KeyError, say_name_not_found( i )
        end
      end

    private

      def lookup i
        x = @h[ i ]
        if x || @done
          x
        else
          lookup_any_value_for_unseen_name_when_not_done i
        end
      end

      def lookup_any_value_for_unseen_name_when_not_done i  # see note #ra-180 in [#044]
        yes = has_name_for_unseen_name_when_not_done i
        if yes
          @h.fetch i
        end
      end

      def has_name_for_unseen_name_when_not_done i
        did_have = false
        while true
          x = @scn.gets
          if ! x
            become_done
            break
          end
          name_i = x.send @meth_i
          store_via_value_and_supposedly_unique_name x, name_i
          if i == name_i
            did_have = true
            break
          end
        end
        did_have
      end

      def say_name_not_found i
        "key not found: #{ i.inspect }"
      end

    public

      def reduce_by i=nil
        if i
          if block_given?
            scn = to_value_stream
            ivar = :"@#{ i }"
            while x = scn.gets
              x.instance_variable_defined?( ivar ) and yield x
            end
          else
            enum_for :reduce_by, i
          end
        else
          ::Enumerator.new do |y|
            scn = to_value_stream
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
          scn = to_value_stream
          while x = scn.gets
            yield x
          end ; nil
        else
          to_enum :each_value
        end
      end

      def each  # where available
        if block_given?
          scn = to_pair_scan
          while pair = scn.gets
            yield( * @each_mapper[ pair ] )
          end
        else
          to_enum :each
        end
      end

      def each_pair
        if block_given?
          scn = to_pair_scan
          if @each_pair_mapper
            while pair = scn.gets
              yield( * @each_pair_mapper[ pair ] )
            end
          else
            while pair = scn.gets
              yield pair.name_i, pair.value_x
            end
          end
        else
          to_enum :each_pair
        end
      end

      def to_simple_stream
        to_value_stream
      end

      def to_pair_scan
        to_name_scan.map_by do |i|
          Pair_.new @h.fetch( i ), i
        end
      end

      def to_value_stream
        if @done
          to_stream_when_done Callback_::Scn
        else
          to_stream_when_not_done Callback_::Scn
        end
      end

      def to_stream
        if @done
          to_stream_when_done Scan_
        else
          to_stream_when_not_done Scan_
        end
      end

    private

      def to_name_scan
        if @done
          to_name_scan_when_done
        else
          to_name_scan_when_not_done
        end
      end

      def to_stream_when_done cls
        d = -1 ; last = @last
        cls.new do
          if d < last
            @h.fetch @a.fetch d += 1
          end
        end
      end

      def to_name_scan_when_done
        d = -1 ; last = @last
        Scan_.new do
          if d < last
            @a.fetch d += 1
          end
        end
      end

      def to_stream_when_not_done cls
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

      def to_name_scan_when_not_done
        d = -1
        Scan_.new do
          if @done
            @a.fetch d += 1
          elsif d < @d
            @a.fetch d += 1
          else
            key_at_unknown_index d += 1
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

      def key_at_unknown_index d
        x = at_unknown_index d
        if x
          x.send @meth_i
        end
      end

      def advance_to_position_if_any d
        while ! @done && @d < d
          at_unknown_index @d + 1
        end ; nil
      end

      def at_unknown_index d
        while @d < d
          x = @scn.gets
          if x
            name_i = x.send @meth_i
            store_via_value_and_supposedly_unique_name x, name_i
          else
            become_done
            x = nil
            break
          end
        end
        x
      end

      def store_via_value_and_supposedly_unique_name x, name_i  # must increment d
        did = nil
        @h.fetch name_i do
          did = true
          @h[ name_i ] = x
        end
        if did
          @d += 1
          @a.push name_i ; nil
        else
          raise ::KeyError, say_wont_clobber_name( name_i )
        end
      end

      def say_wont_clobber_name name_i
        "won't clobber existing '#{ name_i }'"
      end

      def become_done
        @done = true
        @length = @a.length
        @last = @length - 1 ; nil
      end
    end
  end
end
