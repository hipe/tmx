module Skylab::MetaHell

  class Formal::Box::Struct < ::Struct  # all documentation [#054]

    include Formal::Box::InstanceMethods::Readers

    class << self

      alias_method :struct_new, :new

      def new( * )
        super.init_from_members
      end

      def produce_struct_class_from_box box
        struct_new( * box._order ).init_from_box box
      end

      attr_reader :names, :silhouette_box_base_args

    protected  # #protected-not-private

      def init_from_members
        @names = members.freeze
        @silhouette_box_class = Formal::Box
        @silhouette_box_base_args = NIL_ARY__
        self
      end
      #
      NIL_ARY__ = Formal::Box.
        instance_method( :base_init ).arity.times.map{ }.freeze

      def init_from_box box
        @names = members.freeze
        @silhouette_box_class = box.class
        @silhouette_box_base_args = box.get_base_args.freeze
        self
      end
    end

    def initialize( * )
      super
      @order = self.class.names or fail "sanity"
      @hash = Build_hash_proxy__[ self ]
      base_init( * self.class.silhouette_box_base_args )
      nil
    end

    def produce_offspring_box
      self.class.produce_offspring_box_notify
    end

    def self.produce_offspring_box_notify
      ba = @silhouette_box_base_args
      @silhouette_box_class.allocate.instance_exec do
        base_init( * ba )
        self
      end
    end

    Build_hash_proxy__ = -> struct do
      key_h = ::Hash[ struct.class.names.map { |k| [ k, true ] } ].freeze
      Hash_Pxy__.new(
        :key? => key_h.method( :key? ),
        :fetch => -> k, &blk do
          if key_h.key? k
            struct[ k ]
          else
            key_h.fetch k, &blk  # should be fine, right?
          end
        end,
        :dup => -> do
          ::Hash[ struct.class.names.map { |k| [ k, struct[ k ] ] } ]
        end )
    end
    #
    Hash_Pxy__ = MetaHell::Proxy::Nice.new( * %i| key? fetch dup | )
  end
end
