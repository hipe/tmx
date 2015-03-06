module Skylab::SubTree

  module API

    module SubTree_::Models_::Files

      class Mutable_Leaf_Item_  # #stowaway

        # a mutable representation of the metadata around a leaf node

        def initialize input_line
          @subcel_a = nil
          @input_line = input_line
        end

        attr_reader :input_line

        def add_subcel str
          @subcel_a ||= []
          @subcel_a.push str
          NIL_
        end

        def any_free_cel
          if @subcel_a
            @subcel_a * SPACE_
          end
        end

        def add_attribute k, x
          @attribute_box ||= Callback_::Box.new
          @attribute_box.add k, x
          nil
        end

        attr_reader :attribute_box
      end

      class Extensions_

        def initialize & oes_p

          @bx = Callback_::Box.new

          @collection_operation_i_a = nil

          @item_operator_i_a = nil

          @on_event_selectively = oes_p

        end

        def load_extension trio

          ext = Extensions_.const_get( trio.name.as_const, false ).
            new trio, & @on_event_selectively

          __categorize_operation_mode ext

          @bx.add ext.local_normal_name, ext

          ACHIEVED_
        end

        def __categorize_operation_mode ext  # see [#006]:#collection-operations

          if ext.is_collection_operation
            @collection_operation_i_a ||= []
          else
            @item_operator_i_a ||= []
          end.push ext.local_normal_name

          NIL_
        end

        def has_collection_operations
          ! @collection_operation_i_a.nil?
        end

        def receive_mutable_leaf leaf
          ok = true
          if @item_operator_i_a
            @item_operator_i_a.each do |i|
              ok = @bx.fetch( i ).receive_inline_mutable_leaf leaf
              ok or break
            end
          end
          ok
        end

        def receive_the_collection_of_mutable_items row_a
          ok = true
          @collection_operation_i_a.each do |i|
            ok = @bx.fetch( i ).receive_collection_of_mutable_items row_a
            ok or break
          end
          ok
        end
      end
    end
  end
end
