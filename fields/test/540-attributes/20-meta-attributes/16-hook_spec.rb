require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - meta-attributes - hook" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes_meta_attributes

      context "intro" do

        shared_subject :entity_class_ do

          class X_a_ma_Hook_A

            attrs = Attributes::Meta_Attributes.lib.call(
              error: :hook,
            )

            attrs.define_methods self

            attr_accessor :_hello_

            self
          end
        end

        it "write with `on__x__`" do

          o = build_empty_entity_
          o.on__error__

          o.instance_variable_defined?( :@error ) or fail
          o.instance_variable_get( :@error ) and fail
        end

        context "when is written" do

          it "call the proc directly with `receive__x__`" do

            o = _build_one_such_entity

            x = o.receive__error__ :_hi_

            x.should eql "hi: _hi_"

            o._hello_.should eql :_hi_
          end

          it "read back the proc itself with `__x__handler`" do

            o = _build_one_such_entity

            p = o.__error__handler

            _x = p[ :_hey_ ]

            _x.should eql "hi: _hey_"

            o._hello_.should eql :_hey_
          end

          def _build_one_such_entity

            o = build_empty_entity_

            o.on__error__ do |k|
              o._hello_ = k
              "hi: #{ k }"
            end

            o
          end
        end
      end

    # ==
    # ==
  end
end
