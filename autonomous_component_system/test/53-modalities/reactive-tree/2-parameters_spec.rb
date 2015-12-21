require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] modalities - reactive tree - 2. parameters" do

    extend TS_
    use :future_expect
    use :modalities_reactive_tree

    it "call a thing with one required arg (invalid)" do

      future_expect_only :info, :expression, :too_low

      call_ :shoe, :lace, :set_length, :length, '-4'

      expect_failed_

    end

    it "same (valid)" do

      call_ :shoe, :lace, :set_length, :length, '1'

      @result.should eql :_yay_
    end

    it "globbie guy - normal" do

      call_ :shoe, :globbie_guy, :file, [ :one, :two ]

      @result.should eql [ :one, :two ]
    end

    it "complex globby - experimental crazy - defaults work" do

      call_ :shoe, :globbie_complex, :action, :A

      @result.should eql [ :A, false, false, [] ]
    end

    it "complex globby - works sort of.." do

      call_ :shoe, :globbie_complex,
        :action, :A, :is_dry, true, :verbose, :false, :file, [ :a, :b ]

      @result.should eql [ :A, true, :false, [ :a, :b ] ]
    end

    it "options are not truly optional" do

      begin

        call_ :shoe, :globbie_complex,
          :action, :A, :file, [ :a, :b ]
      rescue ::ArgumentError => e
      end

      e.message.should match %r( because of our leaky isomorphism )

    end
  end
end
