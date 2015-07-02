require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-properties examples: flag." do

    # implement a flag-like property...

    # ( the only context ) ->

      before :all do

        MPEF_Entity = Subject_[].call do

          class self::Property < Home_::Entity::Property

            def is_florg
              :zero == @argument_arity
            end

          private

            def florg=
              @argument_arity = :zero
              KEEP_PARSING_
            end
          end
        end

        class MPEF_Business_Widget

          attr_reader :hi, :hey

          MPEF_Entity.call self,

            :florg, :property, :hi,
            :property, :hey

          Enhance_for_test_[ self ]
        end
      end

      it "add and write to fields to your property in the classic way" do
        hi, hey = MPEF_Business_Widget.properties.each_value.to_a
        hi.is_florg.should eql true
        hey.is_florg.should eql false
      end

      it "..and in this case set a custom 'polymorphic_writer_method_proc'." do

        kp = nil

        o = MPEF_Business_Widget.new do
          kp = process_fully_for_test_ :hi, :hey, :ho
        end

        o.hi.should eql true
        o.hey.should eql :ho
        kp.should eql true
      end
    # <-
  end
end
