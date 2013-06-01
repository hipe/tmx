module Skylab::MetaHell

  class Formal::Box::Struct < ::Struct

    # sometimes you want to 'freeze' the box down into a struct-like,
    # so you can access the members with methods etc, or just generally
    # have it behave externally as a struct.  #experimental

    include Formal::Box::InstanceMethods::Readers

    # `produce` - so the upstream box might be an arbitrary box subclass.
    # We, however, will produce an instance of our selfsame ::Struct
    # subclass here, which mixes-in box reader instance methods.
    # You then loose whatever fancy crap your box subclass has, which
    # is probably necessary-esque and fine (you still want to produce
    # actual struct, don't you? it's basically a multiple inheritence
    # problem (read: annoying and you would be doing it wrong)).
    #
    # BUT: when we run filters (like `reduce`-style operations) _on_ the
    # produced struct that themselves produce new boxes on the other end,
    # what would be really neat is if those themselves preserved all the
    # same class associations and `base_init`-style ivars that you would
    # have gotten had you run the filter on the original box (during the
    # state it had when you crated the struct).
    #
    # SO: as such, what we attempt below is to sort of "freeze" the
    # `base_args` as they stand at the time of struct creation (they
    # shouldn't be too volotile anyway, as a matter of design) for use
    # in future result boxes that we create.  BUT ALSO: we need a _slice_
    # of the base args of the box to init ourself with, as if the box
    # were definately just a basic formal box. HACKSLUND

    produce_struct_from_box = nil

    define_singleton_method :produce do |box|
      produce_struct_from_box[ new(* box._order ), box ]
    end

    def self.new( * )   # ocd
      super.class_exec do
        fzn = members.freeze
        define_singleton_method :names do fzn end
        self
      end
    end

    # the alternative to this is that we write the box i.m's in a more
    # abstract way which will both slow things down and make things less
    # readable over there.. (there is nothing wrong with duck-typing
    # a whole entire hash, is there?) so enjoy the fun:
    # (actually it's not that bad. Thank you, Proxy class!!)

    module Pxy
    end

    # (this below is referred to elsewhere as "hash risc")
    Pxy::Hash = MetaHell::Proxy::Nice.new(
      :key?,   # => `has?`, `if?`
      :fetch,  # => `if?`, `each`, `fetch`, `fetch_at_position`, `invert`, `at`
      :dup     # => `to_hash`  # #todo reduce this out, `to_hash` doesn't deserve it
    )

    hash_proxy = -> struct do
      key_h = ::Hash[ struct.class.names.map { |k| [ k, true ] } ].freeze
      Pxy::Hash.new(
        :key? => key_h.method( :key? ),
        :fetch => -> k, &blk do
          if key_h.key? k
            struct[k]
          else
            key_h.fetch k, &blk  # should be fine, right?
          end
        end,
        :dup => -> do
          ::Hash[ struct.class.names.map { |k| [ k, struct[ k ] ] } ]
        end
      )
    end

  protected

    base_args = base_init = nil

    define_method :initialize do |*a|
      super(* a )
      @order = self.class.names
      @hash = hash_proxy[ self ]
      nil_a = base_init.arity.times.map { }
      base_init(* nil_a )
      @box_class = Formal::Box
      @strange_base_args = nil_a
      nil
    end

    produce_struct_from_box = -> struct_kls, box do
      struct = struct_kls.allocate
      hash_pxy = hash_proxy[ struct ]
      struct.instance_exec do
        @order = struct_kls.members
        @hash = hash_pxy  # amazing
        base_init(* base_args.bind( box ).call )  # DODGY
        @box_class = box.class
        @strange_base_args = box.send :base_args
        # (ivars in a struct is a smell so don't get carried away)
      end
      struct_kls.members.each do |n|
        struct[n] = box.fetch n
      end
      struct
    end

    base_args, base_init = [ :base_args, :base_init ].map do |m|
      Formal::Box::InstanceMethods::Readers.instance_method m
    end

    # --*--

    def produce_offspring_box
      # here is the moneyshot of the long comment above..
      #
      box = @box_class.allocate
      box.send :base_init, * @strange_base_args
      box
    end
  end
end
