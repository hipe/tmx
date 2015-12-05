require_relative '../../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - iso. - arg coverage" do

    TS_[ self ]
    use :CLI_isomorphic_methods_client_models_isomorphic_method_parameters

    context "the zero syntax ()" do
      with -> { }
      it "against 0 - o" do with ; ok end
      it "against 1 - x" do with :a ; extra :a end
    end

    context "the one syntax (A)" do
      with -> uno { }
      it "against 0 - m" do with ; missing :uno end
      it "against 1 - o" do with :hi ; ok end
    end

    context "the zero or one syntax ([A])" do
      with -> optioney=nil { }
      it "against 0 - o" do with ; ok end
      it "against 1 - o" do with :hi ; ok end
      it "against 2 - x" do with :hi, :hey ; extra :hey end
    end

    context "the lone glob (*)" do
      with -> * many { }
      it "against 0 - o" do with ; ok end
      it "against 1 - o" do with :hi ; ok end
      it "against 2 - o" do with :hi, :hey ; ok end
    end

    context "the trailing glob (A, *)" do
      with -> file_1, *flle {}
      it "against 0 o m" do with ; missing :file_1 end
      it "against 1 - o" do with :hi ; ok end
      it "against 2 - o" do with :hi, :hey ; ok end
    end

    context "the leading glob (*, A)" do
      with -> *strange, one { }
      it "against 0 - m" do with ; missing :one end
      it "against 1 - o" do with :hi ; ok end
      it "against 2 - o" do with :hi, :hey ; ok end
    end

    context "the infix glob (A, *, B)" do
      with -> this, *is, wild { }
      it "against 0 - m" do with ; missing :this, :wild end
      it "against 1 - m" do with :hi ; missing :wild end
      it "against 2 - o" do with :a, :b ; ok end
      it "against 3 - o" do with :a, :b, :c ; ok end
    end

    context "the trailing optional syntax (A [B])" do
      with -> one, two=nil {}
      it "against 0 - m" do with ; missing :one end
      it "against 1 - o" do with :hi ; ok end
      it "against 2 - o" do with :hi, :hey ; ok end
    end

    context "the leading optional syntax ([A] B)" do
      with -> foo=nil, bar {}
      it "against 0 - m" do with ; missing :bar end
      it "against 1 - o" do with :one ; ok end
      it "against 2 - o" do with :a, :b ; ok end
      it "against 3 - x" do with :a, :b, :c ; extra :c end
    end

    context "the single infix optional (A [B] C)" do
      with -> fee, fi=nil, fo {}
      it "against 0 - m" do with ; missing :fee, :fo end
      it "against 1 - m" do with :a ; missing :fo end
      it "against 2 - o" do with :a, :b ; ok end
      it "against 3 - o" do with :a, :b, :c ; ok end
      it "against 4 - x" do with :a, :b, :c, :d ; extra :d end
    end

    context "the double infix optional with two leading and two trailing" do
      with -> a, b, c=nil, d=nil, e, f { }
      it "against 0 - m" do with ; missing :a, :b, :e, :f end
      it "against 3 - m" do with :a, :b, :c ; missing :f end
      it "against 4 - o" do with :a, :b, :c, :d ; ok end
      it "against 5 - o" do with :a, :b, :c, :d, :e ; ok end
      it "against 6 - o" do with :a, :b, :c, :d, :e, :f ; ok end
      it "against 7 - x" do with :a, :b, :c, :d, :e, :f, :g ; extra :g end
      it "against 8 - x" do with :a, :b, :c, :d, :e, :f, :g, :h ; extra :g, :h end
    end

    context "infix option and glob what the deuce" do
      with -> a, b=nil, *c, e { }
      it "against 0 - m" do with ; missing :a, :e end
      it "against 1 - m" do with :a ; missing :e end
      it "against 2 - o" do with :a, :b ; ok end
      it "against 3 - o" do with :a, :b, :c ; ok end
      it "against 4 - o" do with :a, :b, :c, :d ; ok end
    end
  end
end
