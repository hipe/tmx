require_relative '../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] operations - map - order intro" do

    TS_[ self ]
    use :operations_map

    context "works in simple case" do

      ordered_items_by do

        ignore_common_post_operation_emissions_

        _st = json_file_stream_ 'tyris', 'trix'

        call( :map,
          * real_attributes_,
          :json_file_stream, _st,
          :order, :cost,
        )
      end

      it "money" do
        order_is_ 'trix', 'tyris'
      end

      it "order-by attribute is in effect selected" do
        last_item_.box.fetch( :cost ) == 444 || fail
      end
    end

    context "if there is an item that doesn't have this attribute value" do

      ordered_items_by do

        ignore_common_post_operation_emissions_

        _st = _same_three

        call( :map,
          :json_file_stream, _st,
          * real_attributes_,
          :order, :cost,
        )
      end

      it "goes at *begining* (because nothing is always \"less than\" anything else)" do
        order_is_ 'frim_frum', 'trix', 'tyris'
      end
    end

    context "you can reverse it" do

      ordered_items_by do

        ignore_common_post_operation_emissions_

        _st = json_file_stream_ 'trix', 'tyris'

        call( :map,
          * real_attributes_,
          :json_file_stream, _st,
          :order, :cost,
          :reverse,
        )
      end

      it "goes at end" do
        order_is_ 'tyris', 'trix'
      end
    end

    context "(integrate nils and reverse)" do

      ordered_items_by do

        ignore_common_post_operation_emissions_

        _st = _same_three

        call( :map,
          :json_file_stream, _st,
          * real_attributes_,
          :order, :cost,
          :reverse,
        )
      end

      it "the nil one is at the end" do
        order_is_ 'tyris', 'trix', 'frim_frum'
      end
    end

    def _same_three
      json_file_stream_ 'tyris', 'frim_frum', 'trix'
    end
  end
end
