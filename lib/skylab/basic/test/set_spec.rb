require_relative 'test-support'

module Skylab::Basic::TestSupport::Set

  ::Skylab::Basic::TestSupport[ self ]

  include CONSTANTS

  Basic_ = Basic_

  extend TestSupport_::Quickie

  describe '[ba] set normalization' do

    it "loads" do
      Basic_::Set
    end

    context "define-time failures" do

      it "if you provide an array for 'with_members', must be frozen" do
        -> do
          class Wont_Work
            Basic_::Set[ self, :with_members, %i( foo bar ) ]
          end
        end.should raise_error( ::ArgumentError, %r{\bmust be frozen\b} )
      end
    end

    _MISSING_REQUIRED_RX = /\bmissing required parameter\(s\): \(bar\)/

    _UNREC_PARAM_RX = /\bunrecognized parameter\(s\): \(baz\)/

    context "initialize_basic_set_with_hash" do
      before :all do
        class Foo
          Basic_::Set[ self,
            :with_members, %i( foo bar ).freeze,
            :initialize_basic_set_with_hash ]
          public :initialize_basic_set_with_hash
          def pair
            [ @foo, @bar ]
          end
        end
      end

      it "undershoot" do
        -> do
          build_foo.initialize_basic_set_with_hash foo: true
        end.should raise_error ::ArgumentError, _MISSING_REQUIRED_RX
      end

      it "overshoot" do
        -> do
          build_foo.initialize_basic_set_with_hash foo: true, bar: true, baz: nil
        end.should raise_error ::ArgumentError, _UNREC_PARAM_RX
      end

      it "money" do
        foo = build_foo
        x = foo.initialize_basic_set_with_hash foo: 1, bar: 2
        foo.pair.should eql [ 1, 2 ]
        x.should eql true
      end

      def build_foo
        Foo.new
      end
    end

    context "initialize_basic_set_with_iambic" do
      before :all do
        class Bar
          members_i = %i( foo bar )
          Basic_::Set[ self,
            :with_members, -> { members_i },
            :initialize_basic_set_with_iambic ]
          public :initialize_basic_set_with_iambic
          def pair
            [ @foo, @bar ]
          end
        end
      end

      it "odd" do
        -> do
          build_bar.initialize_basic_set_with_iambic [ :foo, :hi, :bar ]
        end.should raise_error ::ArgumentError, /\bthe count of the #{
          }iambic arguments must be even\. had 3 arguments for /
      end

      it "under" do
        -> do
          build_bar.initialize_basic_set_with_iambic [ :foo, :hi ]
        end.should raise_error ::ArgumentError, _MISSING_REQUIRED_RX
      end

      it "over" do
        -> do
          build_bar.initialize_basic_set_with_iambic %i( foo a bar b baz c )
        end.should raise_error ::ArgumentError, _UNREC_PARAM_RX
      end

      it "money" do
        bar = build_bar
        r = bar.initialize_basic_set_with_iambic [ :foo, :a, :bar, :b ]
        bar.pair.should eql %i( a b )
        r.should eql true
      end

      def build_bar
        Bar.new
      end
    end

    context "error_count - aware" do
      before :all do
        class Error_Counting
          Basic_::Set[ self, :with_members, %i( foo bar ).freeze,
                      :initialize_basic_set_with_iambic ]
          public :initialize_basic_set_with_iambic
          def initialize
            @error_count = 0 ; @msg_a = [ ] ; nil
          end
          attr_reader :bar, :foo, :msg_a
        private
          def bar= s
            if /\A[A-Z]+\z/ =~ s
              @error_count += 1
              @msg_a << "pls dont screm: #{ s }"
            else
              @bar = s
            end ; s
          end
        end
      end

      it "x" do
        ec = build_error_counting
        r = ec.initialize_basic_set_with_iambic [ :foo, :A, :bar, 'BEE' ]
        ec.foo.should eql :A
        ec.bar.should be_nil
        ec.msg_a.should eql [ 'pls dont screm: BEE' ]
        r.should eql false
      end

      def build_error_counting
        Error_Counting.new
      end
    end

    context "customize event handling with 'basic_set_bork_event_listener_p'" do
      before :all do
        class Borker
          Basic_::Set[ self, :with_members, %i( foo bar ).freeze,
                      :initialize_basic_set_with_iambic,
                      :basic_set_bork_event_listener_p, -> ev do
                        @error_cnt += 1
                        boy_howdy ev
                      end ]

          public :initialize_basic_set_with_iambic
          def initialize
            @error_cnt = 0
          end
          attr_reader :error_cnt
        private
          def boy_howdy ev
            "wow#{ ev.xtra_k_a.inspect }"
          end
        end
      end

      it "now you determine the result of the call" do
        brk = build_borker
        s = brk.initialize_basic_set_with_iambic [ :foo, 'x', :baz, 'y' ]
        s.should eql 'wow[:baz]'
        brk.error_cnt.should eql 1
      end

      def build_borker
        Borker.new
      end
    end

    context "gotcha" do

      before :all do
        class Gotcha_Base
          Basic_::Set[ self, :with_members, -> do
            self.class::PURUMS
          end ]
        end
        class Gotcha_Left < Gotcha_Base
          PURUMS = %i( wing )
        end
        class Gotcha_Rite < Gotcha_Base
          PURUMS = %i( ding )
        end
      end

      it "(if you are too clever with memoizing this bites you)" do
        left = Gotcha_Left.new
        rite = Gotcha_Rite.new
        left.basic_set_member_set.should eql [ :wing ].to_set
        rite.basic_set_member_set.should eql [ :ding ].to_set
      end
    end
  end
end
