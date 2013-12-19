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

    context "build special op" do

      box_DSL_class :Wazlo_CUST do

        option_parser do |o|
          o << method( :ziff )
        end
        option_parser_class -> { Wafflo_OP }

        def buckley
          :_yep_
        end
      turn_DSL_off
        def ziff a
          @resulto = "_#{ a * '__' }_" ; a.clear ; nil
        end
        attr_reader :resulto
      end

      class Wafflo_OP
        def initialize
          @base = Long.new []
          @top = List.new []
        end
        attr_reader :base, :top
        Long = ::Struct.new :long
        List = ::Struct.new :list
        def on( * )
        end
        def parse! a
          @p[ a ] ; nil
        end
        def << p
          @p = p ; nil
        end
      end

      it "o" do
        a = %w( buckley --hi )
        invoke a
        box_action.resulto.should eql '_--hi_'
        @result.should eql :_yep_
      end
    end
  end
end
