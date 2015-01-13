require_relative 'test-support'

module Skylab::Callback::TestSupport::OD__

  ::Skylab::Callback::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Subject_ = -> { Callback_::Ordered_Dictionary }

  describe "[cb] ordered dictionary" do

    context "when you make a \"static\" listener class" do  # #needs-indent

      before :all do
        Adapter_Listener_ = Subject_[].new :error, :info
      end

      it "normative" do
        e_a = [] ; i_a = []
        listener = Adapter_Listener_.new -> x { e_a << x }, -> x { i_a << x }
        listener.receive_error_event :x
        listener.receive_info_event :y
        listener.receive_info_event :z
        e_a.should eql [ :x ]
        i_a.should eql [ :y, :z ]
      end

      it "nil callbacks don't get called" do
        one_a = []
        listener = Adapter_Listener_.new -> x { one_a << x }
        listener.receive_error_event :a
        listener.receive_info_event :b
        one_a.should eql [ :a ]
      end

      it "you can reflect on the listeners themselves" do
        listener = Adapter_Listener_.new :foo, :bar
        listener.error_p.should eql :foo
        listener.info_p.should eql :bar
      end

      context "\"static\" listener class with `via_iambic`" do

        it "when good" do
          e_a = [] ; i_a = []
          subject :on_error_event, -> x { e_a << x },
            :on_info_event, -> x { i_a << x }
          @subject.receive_info_event :foo
          @subject.receive_error_event :bar
          i_a.should eql [ :foo ]
          e_a.should eql [ :bar ]
        end

        it "clobbering only takes the last one (for now)" do
          e_a = [] ; i_a = []
          subject :on_error_event, -> x { e_a << x },
            :on_info_event, -> x { i_a << x },
            :on_info_event, -> x { e_a << x }
          @subject.receive_info_event :foo
          @subject.receive_error_event :bar
          e_a.should eql [ :foo, :bar ]
          i_a.length.should be_zero
        end

        it "when strange" do
          -> do
            subject :on_foo_zizzle
          end.should raise_error ::ArgumentError,
            %r(\Adid not match against .+ - 'on_foo_zizzle'\z)
        end

        def subject * x_a
          @subject = Adapter_Listener_.call_via_iambic x_a
        end
      end
    end

    context "inline" do

      it "ok." do
        a = []
        listener = Subject_[].inline :foo, -> x { a << x }, :bar, -> { a << :b }
        listener.receive_foo_event :a
        listener.receive_bar_event
        listener.foo_p[ :c ]
        a.should eql [:a, :b, :c]
      end
    end

    context "merge in other dictionary intersect" do

      it "when no intersect" do
        with inline :wizzle, :W, :wango, :A
        foo_and_bar.should eql [ :F, :B ]
      end

      it "when equal member sets, the argument listener wins" do
        with inline :foo, :F2, :bar, :B2
        foo_and_bar.should eql [ :F2, :B2 ]
      end

      it "when argument listener has unheard of members, they are ignored." do
        with inline :foo, :F2, :bar, :B2, :baz, :Z2
        foo_and_bar.should eql [ :F2, :B2 ]
      end

      it "when there are inside and outside differences, ok" do
        with inline :foo, :F2, :baz, :Z2
        foo_and_bar.should eql [ :F2, :B ]
      end

      it "when there are inside & outside differences (classes reversed)" do
        @subject_listener = inline :foo, :F, :bar, :B
        merge_against Static_Guy_With_Three.new :B2, nil, :BOFFO
        foo_and_bar.should eql [ :F, :B2 ]
      end

      def inline * x_a
        @against_listener = Subject_[].inline_via_iambic x_a
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
        Static_Guy_With_Two = Subject_[].new :foo, :bar
        Static_Guy_With_Three = Subject_[].new :bar, :baz, :boffo
      end
    end
  end
end
