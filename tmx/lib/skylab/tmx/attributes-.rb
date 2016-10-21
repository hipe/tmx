module Skylab::TMX

  Attributes_ = ::Module.new

  module AttributesScratchSpace___

    module Furloughed_NOT_USED_____

      def express_into y
        # @pnode = parsed node
        aval = @pnode.box[ self.class::KEY ]
        if aval
          x = aval.value_x
          if x.nil?
            y << SAY_NULL__
          else
            s = x.to_s
            if s.include? SPACE_
              y << s.inspect  # shyeah right
            else
              y << s
            end
          end
        else
          y << SAY_NONE__
        end
      end
    end

    Order_commonly__ = Home_::Models_::Attribute::Order_commonly

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

      is_lib = "is lib"
      say_is_lib = "lib"

      define_method :_FURLOUGHED_express_into_of do |y, parsed_node|

        self._REVIEW_how_values_are_stored_and_accessed

        aval = parsed_node.box[ is_lib ]
        if aval
          if aval.value_x
            y << say_is_lib
          else
            y << SAY_NO__
          end
        else
          y << SAY_NONE__
        end
      end
    end

    class Attributes_::IsPotentiallyInterestingApplication

      def initialize(*)

      end
    end

    # ==

    class Reorderation__ < ::Proc

      alias_method :group_list_via_item_list, :call
    end

    # ==

    SAY_NO__ = 'no'
    SAY_NONE__ = '-'
    SAY_NULL__ = 'xxx'
  end
end
