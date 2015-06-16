require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attribute - box" do

    extend TS_
    use :attribute_support

    context "`with` - doesn't care about truthiness just has?" do

      subject do
        A_Subject_Module_::Formal_Attribute_Box___[ [
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

        box = A_Subject_Module_::Formal_Attribute_Box___.new

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
