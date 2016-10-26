module Skylab::TMX

  Attributes_ = ::Module.new

  module AttributesScratchSpace___

    Order_commonly__ = -> cls do

      key = cls.const_get :KEY, false

      cls.send :define_method, :plan_for_reorder_via_reorder_request do |req|

        Home_::Models::Reorder::CommonPlan.new req, key
      end
      NIL
    end

    class Attributes_::After

      def initialize(*)

      end

      def plan_for_reorder_via_reorder_request req
        ReorderPlan___.new req
      end

      class ReorderPlan___

        def initialize req
          @attribute = req.attribute
          @__is_forwards = req.is_forwards
        end

        def group_list_via_item_list item_a
          Home_::Magnetics_::GroupList_via_ItemList_to_be_Ordered_by_Chain.new(
            item_a,
            :after,
            @__is_forwards,
          ).execute
        end

        attr_reader :attribute

        def produces_final_group_list
          true
        end
      end
    end

    class Attributes_::Category

      def initialize(*)

      end

      KEY = :category
      Order_commonly__[ self ]
    end

    class Attributes_::Cost

      def initialize(*)

      end

      KEY = :cost
      Order_commonly__[ self ]
    end

    class Attributes_::DocTestManifest

      def initialize(*)

      end

      KEY = :doc_test_manifest
      Order_commonly__[ self ]  # in practice it is probably silly to want
      # to sort by this filename, but this is for testing recursive ordering
    end

    class Attributes_::IsLib

      def initialize(*)

      end

    end

    class Attributes_::IsPotentiallyInterestingApplication

      def initialize(*)

      end
    end
  end
end
