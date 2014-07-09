module Skylab::Callback

  class Event::Factory::Isomorphic  # [#025] :+#deprecation:pending

    def initialize box_module
      @stream_name_to_event_class_cache_h = h = {}  # yes there is danger
      @reso = Resolution__.curry h, box_module
    end

    def call graph, stream_name, * payload_a
      mod = @stream_name_to_event_class_cache_h.fetch stream_name do
        resolve_event_module graph, stream_name
      end
      mod.event graph, stream_name, *payload_a
    end

    alias_method :[], :call  # quack like a ::Proc

  private

    def resolve_event_module graph, stream_name
      @reso.curry( graph, stream_name ).resolve
    end

    class Resolution__
      class << self ; alias_method :curry, :new end
      def initialize h, bm
        @box_mod = bm
        init_const_h
        @stream_name_to_event_class_cache_h = h
      end
      attr_reader :box_mod, :const_h, :stream_name_to_event_class_cache_h
    private
      def init_const_h
        _i_a = @box_mod.constants
        @const_h = ::Hash[ _i_a.map { |i| [ i, true ] } ] ; nil
      end
      def initialize_copy otr
        @box_mod = otr.box_mod
        @const_h = otr.const_h
        @stream_name_to_event_class_cache_h = otr.stream_name_to_event_class_cache_h
      end
    public
      def curry graph, stream_name
        otr = dup
        otr.init_curry graph, stream_name
        otr
      end
    protected
      def init_curry graph, stream_name
        @graph = graph ; @stream_name = stream_name
      end
    public
      def resolve  # the name isn't associated with an event class, so now we
        # walk: first we walk the whole nerk looking for *any* cached clas
        # all the way up.
        @class = nil
        @seen_a = @graph.walk_pre_order( @stream_name, 1 ).
            reduce( [ @stream_name ] ) do |seen, sym|
          @class = @stream_name_to_event_class_cache_h.fetch sym do
            seen << sym ; nil
          end
          @class and break seen
          seen
        end  # #storypoint-035
        if @class
          @cache_these_a = @seen_a
        else
          other_thing
        end
        @cache_these_a.each do |i|
          @stream_name_to_event_class_cache_h[ i ] = @class
        end
        @class
      end

      def other_thing
        @seen_a_ = []
        while 1 < @seen_a.length
          @class = cnst_fetch @seen_a.first do
            @seen_a_ << @seen_a.shift ; nil
          end
          @class and break
        end
        @class or other_thing_yet
        @cache_these_a = @seen_a_ ; nil
      end

      def other_thing_yet
        1 == @seen_a.length or fail 'sanity'
        @err = nil
        @class = cnst_fetch( @seen_a.last ) { |e| @err = e ; nil }
        @class or raise ::NameError, say_error
        @seen_a_ << @seen_a.pop
        @cache_these_a = @seen_a_ ; nil
      end

      def cnst_fetch i, & p
        name = Name.from_variegated_symbol i
        const_i = name.as_const
        if @const_h[ const_i ]
          @box_mod.const_get const_i, false
        else
          1 == p.arity and err = build_name_error( name )
          p[ * err ]
        end
      end

      def build_name_error name
        ::NameError.new "uninitialized constant #{ @box_mod }::#{
          }#{ name.as_const }", name.as_variegated_symbol
      end

      def say_error
        chn = [ * @seen_a_, * @seen_a ].map(& :inspect ).join ' -> '
        "couldn't resolve event stream name chain #{
         }into an en event class name (#{ chn }) - tried to resolve #{
          }#{ @seen_a.last.inspect } into an event class but got \"#{
           }#{ @err }\" (#{ @err.class }) WAT DO"
      end
    end
  end
end
