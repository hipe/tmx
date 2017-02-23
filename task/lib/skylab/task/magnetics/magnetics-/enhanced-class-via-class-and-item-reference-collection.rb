class Skylab::Task

  module Magnetics

    class Magnetics_::EnhancedClass_via_Class_and_ItemTicketCollection < Common_::Dyadic

      def initialize cls, col
        @class = cls
        @collection = col
      end

      def execute  # assumes some manners
        cls = @class
        me = self
        @collection.manner_box.a_.each do |slot_token_sym|
          cls.send :define_method, slot_token_sym do
            me.__manner_slot_setter_for self, slot_token_sym
          end
        end
        cls
      end

      def __manner_slot_setter_for client, slot_sym

        # build such an *object* anew each time it is called (because
        # typically it is only shortlived). the class however is built
        # lazily and cached within the collection so that it could be
        # reused across different enhancements.

        cache = @collection.manner_slot_setter_class_cache___

        _cls = cache.fetch slot_sym do
          x = __build_manner_slot_setter_class_for slot_sym
          cache[ slot_sym ] = x
          x
        end

        _cls.new client, slot_sym, @collection  # #here
      end

      def __build_manner_slot_setter_class_for slot_sym

        col = @collection

        cls = col.begin_dynamic_class__ :MannerSlotSetter, MannerSlotSetter___

        col.manner_box[ slot_sym ].each_pair do |manner_sym, mit|

          cls.send :define_method, manner_sym do
            __set_manner mit
          end
        end

        cls
      end

      # ==

      class MannerSlotSetter___ < ::BasicObject

        def initialize client, slot_sym, col  # #here
          @collection = col
          @client = client
          @slot_symbol = slot_sym
        end

        def members
          @collection.manner_box.fetch( @slot_symbol ).get_keys
        end

        def __set_manner ma
          _class = @collection.__item_via_item_ticket ma
          @client.receive_magnetic_manner _class, ma, @collection
        end
      end
    end
  end
end
