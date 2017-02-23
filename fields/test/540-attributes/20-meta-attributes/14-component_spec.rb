require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - meta-attributes - component" do

      # (this is just a stub - see end of file)

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :attributes_meta_attributes

      context "(context)" do

        shared_subject :entity_class_ do

          class X_a_ma_Component_A

            attrs = Attributes::Meta_Attributes.lib.call(
              roland_808: :component
            )

            ATTRIBUTES = attrs

            def __roland_808__component_association
              Cls
            end

            attr_reader(
              :roland_808,
            )

            class Cls

              class << self
                alias_method :interpret_component, :new
                undef_method :new
              end  # >>

              def initialize st, atr

                @_two = [ st.gets_one, st.gets_one ]
                @_atr = atr
              end

              def yep
                [ @_atr.name.as_variegated_symbol, * @_two ]
              end
            end

            self
          end
        end

        it "yep" do
          o = where_ :roland_808, :x, :y
          o.result.roland_808.yep.should eql [ :roland_808, :x, :y ]
        end
      end

    # ==
    # ==
  end
end

# #see notes in this commit about how this is just a stub
