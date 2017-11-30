require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] stack - common frame - core" do

    TS_[ self ]
    use :memoizer_methods

    context "enhance a class as a `common_frame`" do

      before :all do
        class X_cf_c_Foo
          TS_::Common_Frame.lib.call self,
            :proc, :foo, -> do
               d = 0
               -> { d += 1 }
            end.call,
            :memoized, :proc, :bar, -> do
              d = 0
              -> { d += 1 }
            end.call,
            :inline_method, :bif, -> do
              "_#{ foo }_"
            end,
            :memoized, :inline_method, :baz, -> do
              "<#{ foo }>"
            end
        end
      end

      shared_subject :foo do
        X_cf_c_Foo.new { }
      end

      it "accessing a field's value when it is an ordinary proc" do
        expect( foo.foo ).to eql 1
        expect( foo.foo ).to eql 2
      end

      it "accessing a field's value when it is a memoized proc" do
        expect( foo.bar ).to eql 1
        expect( foo.bar ).to eql 1
      end

      it "accessing a field's value when it is an \"inline method\"" do
        expect( foo.bif ).to eql "_3_"
        expect( foo.bif ).to eql "_4_"
      end

      it "accessing a field's value when it is a memoized inline method" do
        expect( foo.baz ).to eql "<5>"
        expect( foo.baz ).to eql "<5>"
        expect( foo.baz.object_id ).to eql foo.baz.object_id
      end
    end

    context "[ `required` ] `field`s -" do

      before :all do

        class X_cf_c_Bar
          TS_::Common_Frame.lib.call self,
            :globbing, :processor, :initialize,
            :required, :readable, :field, :foo,
            :readable, :field, :bar
        end
      end

      it "failing to provide a required field triggers an argument error" do

        _rx = ::Regexp.new "\\Amissing\\ required\\ field\\ 'foo'\\z"

        begin
          X_cf_c_Bar.new
        rescue ArgumentError => e
        end

        expect( e.message ).to match _rx
      end

      it "passing nil is considered the same as not passing an argument" do

        _rx = ::Regexp.new "\\Amissing\\ required\\ field\\ 'foo'\\z"

        begin
          X_cf_c_Bar.new( :foo, nil )
        rescue ArgumentError => e
        end

        expect( e.message ).to match _rx
      end

      it "passing false is not the same as passing nil, passing false is valid." do
        expect( ( X_cf_c_Bar.new( :foo, false ).foo ) ).to eql false
      end

      it "you can of course pass nil as the value for a non-required field" do
        expect( ( X_cf_c_Bar.new( :foo, :x, :bar, nil ).bar ) ).to eql nil
      end
    end
  end
end
