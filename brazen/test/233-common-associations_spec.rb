require_relative 'test-support'

module Skylab::Brazen::TestSupport

  describe "[br] nodesque - common properties" do

    TS_[ self ]
    use :memoizer_methods

    context "(one)" do

      it "builds" do
        _instance
      end

      context "(with the association)" do

        it "dereferences the association" do
          asc = _instance.dereference :zib_zub
          asc.default_by[].value_x == :digimon || fail
        end
      end

      shared_subject :_instance do

        _subject_module.define do |o|

          o.property_grammatical_injection_by do
            _param_class = Home_.lib_.fields::CommonAssociation::EntityKillerParameter
            _param_class.grammatical_injection
          end

          o.add_association_by_definition_array :zib_zub do
            [ :required, :flag, :property, :deeple, :default, :digimon ]
          end
        end
      end
    end

    def _subject_module
      Home_::CommonAssociations
    end
  end
end
