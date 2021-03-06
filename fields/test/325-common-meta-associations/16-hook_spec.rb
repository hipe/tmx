require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] CMA - hook" do  # #cov2.7 (1x)

    TS_[ self ]
    use :memoizer_methods
    use :attributes_meta_associations

      context "intro" do

        shared_subject :entity_class_ do

          class X_cma_Hook_A

            attrs = Attributes.lib.call(
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

            expect( x ).to eql "hi: _hi_"

            expect( o._hello_ ).to eql :_hi_
          end

          it "read back the proc itself with `__x__handler`" do

            o = _build_one_such_entity

            p = o.__error__handler

            _x = p[ :_hey_ ]

            expect( _x ).to eql "hi: _hey_"

            expect( o._hello_ ).to eql :_hey_
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
