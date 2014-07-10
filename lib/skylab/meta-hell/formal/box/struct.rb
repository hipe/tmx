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

      attr_reader :names, :silhouette_box_args_for_base

    protected  # #protected-not-private

      def init_from_members
        @names = members.freeze
        @silhouette_box_class = Formal::Box
        @silhouette_box_args_for_base = NIL_ARY__
        self
      end
      #
      NIL_ARY__ = Formal::Box.
        instance_method( :init_base ).arity.times.map{ }.freeze

      def init_from_box box
        @names = members.freeze
        @silhouette_box_class = box.class
        @silhouette_box_args_for_base = box.get_arguments_for_base_copy.freeze
        self
      end
    end

    def initialize( * )
      super
      @order = self.class.names or fail "sanity"
      @hash = Build_hash_proxy__[ self ]
      init_base( * self.class.silhouette_box_args_for_base )
      nil
    end

    def get_box_base_copy
      self.class.get_box_base_copy_as_class
    end

    def self.get_box_base_copy_as_class
      x_a = @silhouette_box_args_for_base
      @silhouette_box_class.allocate.instance_exec do
        init_base( * x_a )
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
    Hash_Pxy__ = MetaHell_::Proxy::Nice.new( * %i| key? fetch dup | )
  end
end
