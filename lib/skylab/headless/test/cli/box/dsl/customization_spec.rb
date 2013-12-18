require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Box::DSL

  describe "[hl] CLI box DSL customization" do

    extend TS__

    context "'leaf_action_custom_base_class" do

      it "o" do
        class Hi
          def self.yep ; :_ok_ end
        end
        @box_DSL_class = class Cust_Box_DSL
          Headless::CLI::Box[ self, :DSL, :leaf_action_base_class, Hi ]

          def wippertail
          end
          self
        end

        box_class::Actions::Wippertail.yep.should eql :_ok_
      end

      attr_reader :box_DSL_class
    end
  end
end
