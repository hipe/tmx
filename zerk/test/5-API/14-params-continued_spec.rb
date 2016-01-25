require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - params continued" do

    TS_[ self ]
    use :API

    context "call a thing with one required arg (invalid)" do

      call_by do
        call :shoe, :lace, :set_length, '-4'
      end

      it "fails" do
        fails
      end

      it "emits" do
        _be_this = be_emission :info, :expression, :too_low
        only_emission.should _be_this
      end
    end

    context "same (valid)" do

      call_by do
        call :shoe, :lace, :set_length, '1'
      end

      it "ok" do
        root_ACS_result.should eql :_yay_
      end
    end

    context "globbie guy - normal" do

      call_by do
        call :shoe, :globbie_guy, [ :one, :two ]
      end

      it "the argument uses the glob parameter as it's supposed to" do
        root_ACS_result.should eql [ :ONE, :TWO ]
      end
    end

    context "complex globby - defaults work" do

      call_by do
        call :shoe, :globbie_complex, :action, :A
      end

      it "ok" do
        _x = root_ACS_result
        _x.should eql [ :_fun_, :A, false, false, [] ]
      end
    end

    context "complex globby - glob works" do

      call_by do
        call :shoe, :globbie_complex,
        :action, :A, :is_dry, true, :verbose, :false, :file, [ :a, :b ]
      end

      it "ok" do

        _x = root_ACS_result
        _x.should eql [ :_fun_, :A, true, :false, [ :a, :b ] ]
      end
    end

    context "optional are truly optional (unlike if you tried to use proc defaults)" do

      call_by do
        call :shoe, :globbie_complex,
          :action, :A, :file, [ :a, :b ]
      end

      it "ok" do
        _x = root_ACS_result
        _x.should eql [ :_fun_, :A, false, false, [ :a, :b ] ]
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_21_Another_Shoe ]
    end
  end
end
