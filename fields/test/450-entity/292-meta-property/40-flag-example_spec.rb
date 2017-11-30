require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity meta-properties examples: flag." do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    # implement a flag-like property...

    # ( the only context ) ->

      shared_subject :_subject_module do

        X_e_mp_Entity = Entity.lib.call do

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

        class X_e_mp_Business_Widget

          attr_reader :hi, :hey

          X_e_mp_Entity.call self,

            :florg, :property, :hi,
            :property, :hey

          Entity::Enhance_for_test[ self ]
        end
      end

      it "add and write to fields to your property in the classic way" do
        hi, hey = _subject_module.properties.each_value.to_a
        expect( hi.is_florg ).to eql true
        expect( hey.is_florg ).to eql false
      end

      it "..and in this case set a custom 'argument_scanning_writer_method_proc'." do

        kp = nil

        o = _subject_module.new do
          kp = process_fully_for_test_ :hi, :hey, :ho
        end

        expect( o.hi ).to eql true
        expect( o.hey ).to eql :ho
        expect( kp ).to eql true
      end
    # <-
  end
end
