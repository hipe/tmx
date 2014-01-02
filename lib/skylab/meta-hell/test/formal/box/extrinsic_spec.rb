require_relative 'test-support'

module ::Skylab::MetaHell::TestSupport::Formal::Box::Extr_

  ::Skylab::MetaHell::TestSupport::Formal::Box[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  Box = MetaHell::Formal::Box

  describe "[mh] formal box extrinsic" do

    it "(Open) you can make a \"hash controller\" around an existing hash" do
      h = { foo: :bar }
      box = Box::Open.hash_controller h
      box.add :biz, :baffle
      h.keys.sort.map { |i| [ i, h[i] ] }.
        should eql( [ [ :biz, :baffle ], [ :foo, :bar ] ] )
    end

    Field_ = ::Struct.new :name_i, :label

    it "box map - array map makes new arrays, so .." do
      field_box = Box::Open.new
      field_box.add :foo, Field_[ :foo, "the Foo" ]
      field_box.add :bar, Field_[ :foo, "the Bar" ]
      label_box = field_box.each.box_map( & :label )
      label_box.fetch( :foo ).should eql( 'the Foo' )
      label_box.fetch( :bar ).should eql( 'the Bar' )
      label_box.length.should eql( 2 )
    end

    it "an arity of 3 is not supported for each" do
      box = Box.from_iambic :foo, :one, :bar, :two
      -> do
        box.each { |a, b, c| }
      end.should raise_error( ::ArgumentError, /arity not supported: 3\z/ )
    end

    it "freezing is what it sounds like" do
      box = Box::Open.from_iambic :foo, :two
      box.add :bar, :two
      box.freeze
      -> do
        box.add :bizzle, :three
      end.should raise_error( /can't modify frozen Array/ )
    end

    it "partition_where_name_in!" do
      one = Box::Open.from_iambic :eeny, :E, :meeny, :M, :miney, :I, :moe, :O
      two = one.partition_where_name_in! :eeny, :miney
      one._order.should eql( [ :meeny, :moe ] )
      one.values.should eql( [ :M, :O ] )
      two._order.should eql( [ :eeny, :miney ] )
      two.values.should eql( [ :E, :I ] )
    end

    it "clear" do
      one = Box::Open.from_iambic :x, :y, :z, :q
      one.clear.should eql( nil )
      one.length.should eql( 0 )
      one.instance_variable_get( :@hash ).length.should eql( 0 )
    end

    it "sort_names_by!" do
      box = Box::Open.from_iambic :z, :Z, :x, :X, :y, :Y
      desired_order = [ :x, :z, :y ]
      box.sort_names_by!( & desired_order.method( :index ) )
      box._order.should eql( desired_order )
    end

    it "to_hash" do
      h1 = { a: :A, b: :B }
      box = Box.from_hash h1
      h2 = box.to_hash
      h1.should eql( h2 )
      ( h1.object_id == h2.object_id ).should eql( false )
    end

    it "invert" do
      box = Box.from_hash a: :A, b: :B
      box_ = box.invert
      box_._order.should eql( [ :A, :B ] )
      box_.values.should eql( [ :a, :b ] )
    end

    context "fuzzy match" do

      class MyBox < Box
      private

        def fuzzy_reduce wat
          _fuzzy_reduce wat, -> k, item, y do
            y << item.label
            y << item.label.reverse  # clever way to demonstrate many-to-one
          end
        end
      end

      MY_BOX_ = MyBox.from_iambic :foo, Field_[ :foo, 'the Foo' ],
                                  :bar, Field_[ :bar, 'the Bar' ]

      it "needs improvement" do

        a = -> do  # #todo - you're probably thinking what i'm thinking
          :there_were_none
        end,
        -> md do
          "you want #{ md.string_matched } (#{ md.item.name_i.inspect })"
        end,
        -> when_many do
          "did you mean #{ when_many.values.map { |md| md.item.label } *
            ' or ' }?"
        end

        x = MY_BOX_.fuzzy_fetch 'x', *a
        x.should eql( :there_were_none )

        x = MY_BOX_.fuzzy_fetch 'the bar', *a
        x.should eql( "you want the Bar (:bar)" )

        x = MY_BOX_.fuzzy_fetch 'rab eht', *a
        x.should eql( "you want raB eht (:bar)" )

        x = MY_BOX_.fuzzy_fetch 'the ', *a
        x.should eql( "did you mean the Foo or the Bar?" )
      end
    end

    it "fetch_at_position, last" do
      box = Box.from_iambic :foo, :F, :bar, :B, :baz, :Z
      box.fetch_at_position( 0 ).should eql( :F )
      box.fetch_at_position( 1 ).should eql( :B )
      box.fetch_at_position( 2 ) { :Y }.should eql( :Z )
      box.fetch_at_position( 3 ) { :Y }.should eql( :Y )
      x = box.fetch_at_position 3 do |idx|
        idx + 7
      end
      x.should eql( 10 )
      box.last.should eql( :Z )
    end

    it "hax, hax, hax-hax-hax-hax" do
      box = Box.from_iambic :foo, :F
      a, h = box._raw_constituency
      a.each { |i| h[ i ] = :"_#{ h[ i ] }_" }
      box.to_a.should eql( [ :_F_ ] )
    end
  end
end
