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
