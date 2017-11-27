require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - magnetics - math ellipsify" do

    TS_[ self ]
    use :string

    it "loads" do
      subject
    end

    context "ellipsify - out of box usage" do

      it "loads" do
        subject
      end

      it "empty empty" do
        expect( subject( EMPTY_S_ ) ).to eql EMPTY_S_
      end

      _FIFTEEN = '012345678901234'
      it "on the money" do
        expect( subject( _FIFTEEN ) ).to eql _FIFTEEN
      end

      it "work" do
        _sixteen = "#{ _FIFTEEN }5"
        _s = subject _sixteen
        expect( _s ).to eql '01234567890[..]'
      end

      def subject * a
        super().ellipsify( * a )
      end
    end

    context "ellipsify - provide args explicitly" do

      it "custom width" do
        expect( subject[ '012345', 5 ] ).to eql '0[..]'
      end

      it "custom glyph, use iambic args" do
        expect( subject.via( :input_string, '012345', :max_width, 5, :glyph, '*' ) ).to eql '0123*'
      end

      def subject
        super.ellipsify
      end
    end

    context "ellipsify - `backwards_curry` with arglist" do

      it "curry with two args, call with one (just like a true proc)" do
        proc_like = subject.backwards_curry[ '[...]', 6 ]
        expect( proc_like[ '0123456' ] ).to eql '0[...]'
        expect( proc_like[ '012345' ] ).to eql '012345'
      end

      it "curry with one arg, call with two (NOTE ORDER)" do
        proc_like = subject.backwards_curry[ '•' ]
        expect( proc_like[ '01234', 4 ] ).to eql '012•'
      end

      it "curry multiple times" do
        proc_one = subject.backwards_curry[ 'A' ]
        proc_two = proc_one.backwards_curry[ 3 ]
        expect( proc_two[ '0123' ] ).to eql '01A'
      end

      def subject
        super.ellipsify
      end
    end

    context "ellipsify - curry with iambic" do

      it "ok" do
        proc_like = subject.curry_with :max_width, 5
        expect( proc_like[ '012345' ] ).to eql '0[..]'
      end

      it "curry multiple times" do
        proc_one = subject.curry_with :glyph, '•'
        proc_two = proc_one.curry_with :max_width, 3
        expect( proc_two[ '0123' ] ).to eql '01•'
      end

      def subject
        super.ellipsify
      end
    end

    alias_method :subject, :subject_module_
  end
end
