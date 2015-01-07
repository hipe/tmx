module Skylab::Callback

  class Event::Factory::Structural

    # construct a structural factory with 1 arg - a max number of unique
    # struct classes to produce that you will cache. The produced factory
    # object will respond to `event` whose payload argument is expected to be
    # 1 hash, this factory will use an existing cached struct if one
    # exists for those keys (in that order), or create a new one on the
    # fly and cache it as necessary. The result from the call to `event`
    # is the simple struct instance of the struct class that was created
    # on the fly (at some point).
    #
    # optionally you can provide a base class at which point all
    # hell breaks loose, also a box module to put them in.
    #
    # #not-most-recent of #nichepoint [#015] (newer might be better)

    def event esg, sn, payload_x
      @event[ esg, sn, payload_x ]
    end

  private

    def initialize sanity, base_class=nil, box_module=nil

      count = 0

      cache_h = ::Hash.new do |h, key_a|
        if ( count += 1 ) > sanity
          fail "too many struct classes to constrcut: #{ count } (#{
            }#{ key_a.inspect } after #{
            }#{ cache_h.keys.map(& :inspect ).join ', ' }.)"
        else
          h[ key_a ] = produce_event_class key_a
        end
      end

      @produce_event_class_hookback = nil

      self.base_class = base_class if base_class

      self.box_module = box_module if box_module

      @event = -> esg, sg, payload_h do
        build_event cache_h[ payload_h.keys ], esg, sg, payload_h
      end
    end

    # `base_class=` your class must construct with 2 args.
    # produced classes produce objects that *always* set the ivars
    # to the payload_h, and never use setters (for now) (but we will
    # call super() last if you want to derk with things).
    #
    # Whether you want it or not, and whether or not you already defined
    # it, your class gets m.m's: `members` and i.m's: [attr_readers
    # for all the members] and `to_hash`.

    def base_class= base_class
      @produce_event_class = -> key_a do
        key_a.freeze  # give me that - it's mine
        kls = ::Class.new base_class
        kls.class_exec do
          define_singleton_method :members do key_a end
          key_a.each do |sym| attr_reader sym end
          ivar_h = ::Hash[ key_a.map { |k| [ k, :"@#{ k }" ] } ]
          define_method :initialize do |esg, stream_symbol, payload_h|
            payload_h.each do |k, v|
              instance_variable_set ivar_h.fetch( k ), v
            end
            super esg, stream_symbol
          end
          define_method :to_hash do
            ::Hash[ key_a.map { |k| [ k, instance_variable_get( ivar_h[k] ) ] }]
          end
        end
        kls
      end
      @build_event = -> kls, esg, sn, pay_h do
        kls.new esg, sn, pay_h
      end
      base_class
    end

    def produce_event_class key_a
      @produce_event_class ||= -> k_a do
        ::Struct.new( * k_a )
      end
      kls = @produce_event_class[ key_a ]
      @produce_event_class_hookback[ key_a, kls ] if
        @produce_event_class_hookback
      kls
    end

    -> do

      constantify = -> sym do
        Callback_::Name.via_variegated_symbol( sym ).as_const
      end

      define_method :box_module= do |box_mod|
        @produce_event_class_hookback = -> key_a, kls do
          const = key_a.map{ |sym| constantify[ sym ] }.join( UNDERSCORE_ ).intern
          if box_mod.const_defined? const, false
            raise ::RuntimeError, "collision with pre-existing const:#{
              }#{ box_mod }::#{ const } - be sure that your factories exist #{
              }one-to-one with your modules when you connect them."
          else
            box_mod.const_set const, kls
          end
          nil
        end
        box_mod
      end

    end.call

    def build_event klass, graph, stream, payload_h
      @build_event ||= -> kls, esg, sn, pay_h do
        kls.new(* kls.members.map { |k| pay_h.fetch k } )
      end
      # (hypothetically if we came in through the front door it is unlikely
      # that we are skipping any elements in `payload_h`)
      @build_event[ klass, graph, stream, payload_h ]
    end
  end
end
