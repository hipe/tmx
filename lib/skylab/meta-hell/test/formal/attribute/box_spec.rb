require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Formal::Attribute::Box

  ::Skylab::MetaHell::TestSupport::Formal::Attribute[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[mh] formal attribute box" do

    extend TS_

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

        ea = subject.reduce_with :flavor

        a = ea.to_a
        a.length.should eql 3

        a.map( & :local_normal_name ).should eql [ :one, :three, :four ]

        box = ea.select do |x|
          x[ :flavor ]
        end

        box.length.should eql( 2 )
      end
    end

    context "`select` - " do

      memoize_ :box do

        st = ::Struct.new :name, :ready, :flavor

        box = MetaHell_::Formal::Attribute::Box.new

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

      it "select then each pair" do
        ks = [] ; vs = []
        box.select( & :ready ).each_pair do |k, v|
          ks << k ; vs << v
        end
        ks.should eql [ :one, :three ]
        vs.first.flavor.should eql :bland
      end

      it "select then each value" do
        xs = []
        box.select( & :ready ).each_value do |x|
          xs << x
        end
        xs.first.flavor.should eql :bland
      end

      it "select then map NEAT" do
        x = box.select(& :ready ).map(& :name )
        x.should eql( [:foo, :baz] )
      end
    end
  end
end
