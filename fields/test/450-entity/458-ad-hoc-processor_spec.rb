require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - concerns - ad-hoc" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    context "for e.g a DSL extension that adds properties" do

      shared_subject :_subject_module do

        class X_e_ahp_Base

          Entity.lib.call self do
            o :ad_hoc_processor, :gazoink, -> x { X_e_ahp_Gazoink.new( x ).go }
          end
        end

        class X_e_ahp_Gazoink

          def initialize pc
            @pc = pc
          end

          def go

            _a = @pc.upstream.gets_one
            _a.each do | sym |
              @pc.add_property_with_variegated_name sym
            end
            true
          end
        end

        class X_e_ahp_Child < X_e_ahp_Base

          Entity.lib.call self do
            o :argument_scanning_writer_method_name_suffix, :'='
            def foo=
              @foo = gets_one
            end
            o :gazoink, [ :bar, :baz ]
            def biff=
            end
          end

          attr_reader :foo, :baz

          Entity::Enhance_for_test[ self ]
        end
      end

      it "enhances" do
        _subject_module || fail
      end

      it "reflects" do
        _subject_module.properties.get_keys.
          should eql [ :foo, :bar, :baz, :biff ]
      end

      it "writes" do
        o = _subject_module.with :foo, :F, :baz, :B
        o.foo.should eql :F
        o.baz.should eql :B
      end
    end

    # ==
    # ==
  end
end
