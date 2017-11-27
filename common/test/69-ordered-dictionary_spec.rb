require_relative 'test-support'

module Skylab::Common::TestSupport

  describe "[co] ordered dictionary" do

    context "when you make a \"static\" listener class" do  # #needs-indent

      before :all do
        X_od_Listener = Home_::Ordered_Dictionary.new :error, :info
      end

      it "normative" do
        e_a = [] ; i_a = []
        listener = X_od_Listener.new -> x { e_a << x }, -> x { i_a << x }
        listener.receive_error_event :x
        listener.receive_info_event :y
        listener.receive_info_event :z
        expect( e_a ).to eql [ :x ]
        expect( i_a ).to eql [ :y, :z ]
      end

      it "nil callbacks don't get called" do
        one_a = []
        listener = X_od_Listener.new -> x { one_a << x }
        listener.receive_error_event :a
        listener.receive_info_event :b
        expect( one_a ).to eql [ :a ]
      end

      it "you can reflect on the listeners themselves" do
        listener = X_od_Listener.new :foo, :bar
        expect( listener.error_p ).to eql :foo
        expect( listener.info_p ).to eql :bar
      end

      context "\"static\" listener class with `via_iambic`" do

        it "when good" do
          e_a = [] ; i_a = []
          subject :on_error_event, -> x { e_a << x },
            :on_info_event, -> x { i_a << x }
          @subject.receive_info_event :foo
          @subject.receive_error_event :bar
          expect( i_a ).to eql [ :foo ]
          expect( e_a ).to eql [ :bar ]
        end

        it "clobbering only takes the last one (for now)" do
          e_a = [] ; i_a = []
          subject :on_error_event, -> x { e_a << x },
            :on_info_event, -> x { i_a << x },
            :on_info_event, -> x { e_a << x }
          @subject.receive_info_event :foo
          @subject.receive_error_event :bar
          expect( e_a ).to eql [ :foo, :bar ]
          expect( i_a.length ).to be_zero
        end

        it "when strange" do
          expect( -> do
            subject :on_foo_zizzle
          end ).to raise_error ::ArgumentError,
            %r(\Adid not match against .+ - 'on_foo_zizzle'\z)
        end

        def subject * x_a
          @subject = X_od_Listener.call_via_iambic x_a
        end
      end
    end

    context "inline" do

      it "ok." do
        a = []
        listener = _subject_module.inline :foo, -> x { a << x }, :bar, -> { a << :b }
        listener.receive_foo_event :a
        listener.receive_bar_event
        listener.foo_p[ :c ]
        expect( a ).to eql [:a, :b, :c]
      end
    end

    context "merge in other dictionary intersect" do

      it "when no intersect" do
        with inline :wizzle, :W, :wango, :A
        expect( foo_and_bar ).to eql [ :F, :B ]
      end

      it "when equal member sets, the argument listener wins" do
        with inline :foo, :F2, :bar, :B2
        expect( foo_and_bar ).to eql [ :F2, :B2 ]
      end

      it "when argument listener has unheard of members, they are ignored." do
        with inline :foo, :F2, :bar, :B2, :baz, :Z2
        expect( foo_and_bar ).to eql [ :F2, :B2 ]
      end

      it "when there are inside and outside differences, ok" do
        with inline :foo, :F2, :baz, :Z2
        expect( foo_and_bar ).to eql [ :F2, :B ]
      end

      it "when there are inside & outside differences (classes reversed)" do
        @subject_listener = inline :foo, :F, :bar, :B
        merge_against Static_Guy_With_Three.new :B2, nil, :BOFFO
        expect( foo_and_bar ).to eql [ :F, :B2 ]
      end

      def inline * x_a
        @against_listener = _subject_module.inline_via_iambic x_a
      end

      def with argument_listener
        @subject_listener = Static_Guy_With_Two.new :F, :B
        merge_against argument_listener
      end

      def merge_against argument_listener
        @subject_listener.merge_in_other_listener_intersect argument_listener
        nil
      end

      def foo_and_bar
        [ @subject_listener.foo_p, @subject_listener.bar_p ]
      end

      before :all do
        cls = Home_::Ordered_Dictionary
        Static_Guy_With_Two = cls.new :foo, :bar
        Static_Guy_With_Three = cls.new :bar, :baz, :boffo
      end
    end

    def _subject_module
      Home_::Ordered_Dictionary
    end
  end
end
