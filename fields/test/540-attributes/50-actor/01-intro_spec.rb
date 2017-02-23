require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - actor - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes_actor

    # ==

      it "left loads" do
        _left_class
      end

      it "this i.m loads" do
        Attributes.lib::Lib::PolymorphicProcessingInstanceMethods
      end

      it "i.m only loads" do
        _instance_methods_only_class
      end

      it "right loads" do
        _right_class
      end

      it "hybrid loads" do
        _hybrid_class
      end

      it "left writes" do
        _given :_left_class
        new_with_ :jiang, :J
        @session_.jiang.should eql :J
      end

      it "i.m only writes" do
        _given :_instance_methods_only_class
        new_with_ :foo, :F
        @session_.foo.should eql :F
      end

      it "right writes" do
        _given :_right_class
        new_with_ :foo, :F
        @session_.foo.should eql :F
      end

      it "hybrid writes" do
        _given :_hybrid_class
        new_with_ :bar, :B, :qing, :Q
        [ @session_.bar, @session_.qing ].should eql [ :B, :Q ]
      end

      it "unrec left" do
        _given :_left_class
        _unrec
      end

      it "unrec right" do
        _given :_right_class
        _unrec
      end

      it "unrec hybrid" do
        _given :_hybrid_class
        _unrec
      end

      def _unrec
        @session_ = @class_.new
        begin
          process_argument_scanner_fully_via_ :zoik
        rescue Home_::ArgumentError => e
        end
        e.message.should eql "unrecognized attribute 'zoik'"
      end

      it "im - `process_iambic_fully`" do
        sess = _hybrid_class.new
        sess.send :process_iambic_fully, [ :qing, :Q ]
        sess.qing.should eql :Q
      end

      it "mm - `new_with`, `new_via_iambic`" do
        _given :_hybrid_class
        @session_ = @class_.new_with :jiang, :J, :bar, :B
        _this.should eql [ :J, :B ]
      end

      it "i.m - `new_with` (makes a dup)" do

        @session_ = _hybrid_class.new_with :jiang, :J, :bar, :B
        otr = @session_.send :new_with, :jiang, :K
        _this.should eql [ :J, :B ]
        @session_ = otr
        _this.should eql [ :K, :B ]
      end

      def _this
        [ @session_.jiang, @session_.bar ]
      end

      context "mm - `new_via_argument_scanner_passively`" do

        shared_subject :_tuple do

          st = _build_this_argument_scanner
          sess = _hybrid_class.new_via_argument_scanner_passively st
          [ st.head_as_is, sess.jiang, sess.bar ]
        end

        it "writes" do
          _tuple[ 1, 2 ].should eql [ :J, :B ]
        end

        it "stream" do
          _tuple[ 0 ].should eql :Z
        end
      end

      it "mm - `with`" do
        _given :_hybrid_class
        _ = @class_.with :jiang, :J, :bar, :B
        _.should eql [ :JIANG, :J, :BAR, :B ]
      end

      it "passive - none" do

        @session_ = _hybrid_class.new
        x = process_argument_scanner_passively_ the_empty_argument_scanner_
        x.should eql true
      end

      context "passive - some" do

        shared_subject :_tuple do
          @session_ = _hybrid_class.new
          st = _build_this_argument_scanner
          x = process_argument_scanner_passively_ st
          [ x, st.head_as_is, @session_.jiang, @session_.bar ]
        end

        it "writes" do
          _tuple[ 2, 2 ].should eql [ :J, :B ]
        end

        it "result" do
          _tuple.fetch( 0 ).should eql true
        end

        it "leaves parse at first unrec" do
          _tuple.fetch( 1 ).should eql :Z
        end
      end

      def _build_this_argument_scanner
        argument_scanner_via_ :jiang, :J, :bar, :B, :Z
      end

      def _given m
        @class_ = send m ; nil
      end

      shared_subject :_left_class do

        class X_a_a_i_NoSee_Left

          attrs = Attributes::Actor.lib.call( self,
            jiang: nil,
            xiao: nil,
            qing: nil,
          )

          attr_reader( * attrs.symbols )

          self
        end
      end

      shared_subject :_instance_methods_only_class do

        class X_a_a_i_NoSee_IM_Only

          include Attributes.lib::Lib::PolymorphicProcessingInstanceMethods

        private

          def foo=
            @foo = gets_one_polymorphic_value ; true
          end

          def bar=
            @bar = gets_one_polymorphic_value ; true
          end

        public

          attr_reader :foo, :bar

          self
        end
      end

      shared_subject :_right_class do

        class X_a_a_i_NoSee_Right

          Attributes::Actor.lib.call self

        private

          def foo=
            @foo = gets_one_polymorphic_value ; true
          end

          def bar=
            @bar = gets_one_polymorphic_value ; true
          end

        public

          attr_reader :foo, :bar

          self
        end
      end

      shared_subject :_hybrid_class do

        class X_a_a_i_NoSee_Hybrid

          attrs = Attributes::Actor.lib.call( self,
            jiang: nil,
            xiao: nil,
            qing: nil,
          )

          attr_reader( * attrs.symbols )

        private

          def foo=
            @foo = gets_one_polymorphic_value ; true
          end

          def bar=
            @bar = gets_one_polymorphic_value ; true
          end
        public

          def execute
            [ :JIANG, @jiang, :BAR, @bar ]
          end

          attr_reader :foo, :bar

          self
        end
      end
    # ==
  end
end
# #tombstone - `ignore` keyword
# #tombstone - `properties` keyword
