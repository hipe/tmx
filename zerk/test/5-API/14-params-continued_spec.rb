require_relative '../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ze] API - params continued", wip: true do

    TS_[ self ]
    use :future_expect
    # use :modalities_reactive_tree

    it "call a thing with one required arg (invalid)" do

      self._BREAKUP

      future_expect_only :info, :expression, :too_low

      call_root_ACS :shoe, :lace, :set_length, :length, '-4'

      expect_failed_
    end

    it "same (valid)" do

      call_root_ACS :shoe, :lace, :set_length, :length, '1'

      @result.should eql :_yay_
    end

    it "globbie guy - normal" do

      call_root_ACS :shoe, :globbie_guy, :file, [ :one, :two ]

      @result.should eql [ :one, :two ]
    end

    it "complex globby - experimental crazy - defaults work" do

      call_root_ACS :shoe, :globbie_complex, :action, :A

      @result.should eql [ :A, false, false, [] ]
    end

    it "complex globby - works sort of.." do

      call_root_ACS :shoe, :globbie_complex,
        :action, :A, :is_dry, true, :verbose, :false, :file, [ :a, :b ]

      @result.should eql [ :A, true, :false, [ :a, :b ] ]
    end

    it "options are not truly optional" do

      begin

        call_root_ACS :shoe, :globbie_complex,
          :action, :A, :file, [ :a, :b ]
      rescue ::ArgumentError => e
      end

      e.message.should match %r( because of our leaky isomorphism )

    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_21_Another_Shoe ]
    end
  end
end
