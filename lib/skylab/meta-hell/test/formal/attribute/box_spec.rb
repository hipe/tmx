require_relative 'test-support'

module ::Skylab::MetaHell::TestSupport::Formal::Attribute::Box

  ::Skylab::MetaHell::TestSupport::Formal::Attribute[ TS__ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[mh] formal attribute box" do

    extend TS__

    context "`with` - doesn't care about truthiness just has?" do

      subject -> do
        MetaHell_::Formal::Attribute::Box[ [
          [:one, { name: :foo, ready: true, flavor: :bland } ],
          [:two, { name: :bar, ready: false} ],
          [:three, { name: :baz, ready: true, flavor: :spicy } ],
          [:four, { name: :boffo, ready: false, flavor: nil } ]
        ] ]
      end

      it "like so" do
        ea = subject.with :flavor
        ea.should be_respond_to( :filter )
        a = ea.to_a
        a.length.should eql(3)
        a.map(&:local_normal_name).should eql( [:one, :three, :four] )
        box = ea.select { |x| x[:flavor] }
        box.length.should eql( 2 )
      end
    end

    context "`select` - " do
      memoize :box, -> do
        st = ::Struct.new :name, :ready, :flavor
        box = MetaHell::Formal::Attribute::Box.new
        class << box
          public :add
        end
        box.add :one,   st[ :foo,   true, :bland ]
        box.add :two,   st[ :bar,   false ]
        box.add :three, st[ :baz,   true,  :spicy ]
        box.add :four,  st[ :boffo, false, nil ]
        box
      end

      it "Hash#select result is Hash, Array#select is Array, SO:" do
        x = box.select(& :ready )
        x.class.should eql( box.class )
        x.length.should eql( 2 )
      end

      it "select then each with 2 args" do
        ks = [] ; vs = []
        box.select( &:ready ).each do |k, v|
          ks << k ; vs << v
        end
        ks.should eql( [:one, :three] )
        vs.first.flavor.should eql( :bland )
      end

      it "select then each with 1 arg" do
        xs = []
        box.select(& :ready ).each do |x|
          xs << x
        end
        xs.first.flavor.should eql( :bland )
      end

      it "select then map NEAT" do
        x = box.select(& :ready ).map(& :name )
        x.should eql( [:foo, :baz] )
      end
    end
  end
end
