require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - actor - curry the curry" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes

    # ==

      context "(context 1)" do

        shared_subject :_class do

          class X_a_a_ctc_NoSee

            Attributes::Actor.lib.call( self,
              :very_volatile,
              :somewhat_volatile,
              :a_medium_amount_of_volatile,
              :not_very_volatile,
              :almost_not_at_all_volatile,
              :static,
            )

            def execute
              [ @very_volatile, @somewhat_volatile,
                @a_medium_amount_of_volatile, @not_very_volatile,
                @almost_not_at_all_volatile, @static ]
            end

            self
          end
        end

        it "cw., cw." do

          _cls = _class

          ca = _cls.curry_with( :static, :S, :not_very_volatile, :NVV )

          ca2 = ca.curry_with( :static, :s, :somewhat_volatile, :SV )

          _ = ca2.call_via( :very_volatile, :V, :a_medium_amount_of_volatile, :AM,
                   :almost_not_at_all_volatile, :ANVAA )

          _.should eql [ :V, :SV, :AM, :NVV, :ANVAA, :s ]
        end

        it "bc., bc." do

          _cls = _class

          ca = _cls.backwards_curry[ :ANVAA, :S ]

          ca2 = ca.backwards_curry[ :AMV, :NVV ]

          _wow = ca2.call :VV, :SV

          _wow.should eql [:VV, :SV, :NVV, :AMV, :S, :ANVAA]

        end
      end
    # ==
  end
end
