require_relative 'test-support'

module ::Skylab::MetaHell::TestSupport::Formal::Box::Struct

  ::Skylab::MetaHell::TestSupport::Formal::Box[ Struct_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ MetaHell::Formal::Box }::Struct - from box" do

    extend Struct_TestSupport

    define_method :struct, & MetaHell::FUN.memoize[ -> do
      o = { sure: :whaver, this: :that, ming: :mang }
      box = MetaHell::Formal::Box.from_hash o
      box.to_struct
    end ]

    context "looks and works basically like a stuct (b.c it is)" do

      it "[] for existing members - as with struct, fetches" do
        struct[:ming].should eql( :mang )
      end

      it "`foo` - as with struct, you can access the members by name" do
        struct.sure.should eql( :whaver )
      end

      it "[] for non existend members - as with struct, borks" do
        begin
          struct[:not_there]
        rescue ::NameError =>e
        end
        e.should be_kind_of( ::NameError )
        e.message.should eql( "no member 'not_there' in struct" )
      end

      it "it *will* allow you to overwrite vital methods, so be careful" do
        struct = MetaHell::Formal::Box.from_hash( each: :peach ).to_struct
        struct.each.should eql( :peach )
      end

      it "`members` - as with struct, array of names (keys) (members)" do
        struct.members.should eql( [ :sure, :this, :ming ] )
      end
    end

    context "if you try to create a struct from the empty box" do

      it "- borks because of real life" do
        box = MetaHell::Formal::Box.new
        begin
          box.to_struct
        rescue ::ArgumentError => e
        end
        e.should be_kind_of( ::ArgumentError )
        e.message.should eql( 'wrong number of arguments (0 for 1+)' )
      end
    end

    context "has a value-added feature enriched value prop" do

      it "`if?` - is a fun box methd you can try at home with the family" do
        struct = self.struct
        ming = struct.if? :ming, -> x { "yes:#{ x }" }, -> { :no }
        ping = struct.if? :ping, -> x { "yes:#{ x }" }, -> { :no }
        ming.should eql( 'yes:mang' )
        ping.should eql( :no )
      end
    end

    context "when you call `reduce` -type operations that produce new boxes" do

      it "- it would be too crazy to produce a new struct (kls/inst)" do

        a = struct.select do |k, v|
          :whaver == v || :ming == k
        end
        b = struct.select do |v|
          :that == v
        end
        ( a.class == struct.class ).should eql( false )
        a.names.should eql( [ :sure, :ming ] )
        a.values.should eql( [ :whaver, :mang ] )
        b.names.should eql( [ :this ] )
        b.values.should eql( [ :that ] )
      end
    end
  end

  describe "#{ MetaHell::Formal::Box }::Struct - like tradtional struct" do

    define_method :wiz_bang, & MetaHell::FUN.memoize[ -> do
       MetaHell::Formal::Box.const_get :Struct, false
       MetaHell::Formal::Box::Struct.new :wiz, :bang
    end ]

    it "try and construct it with wrong size - struct size differs (Argum.." do
      begin
        wiz_bang.new :one, :two, :three
      rescue ::ArgumentError => e
      end
      e.message.should eql( 'struct size differs' )
    end

    it "but construct it with the right size - you have awesome" do
      st = wiz_bang.new :piz, :pang
      st.wiz.should eql( :piz )
      box = st.filter{ |v| :pang == v }.to_box
      box.names.should eql( [ :bang ] )
    end

    it "construct it with no args" do
      st = wiz_bang.new
      nils_bohr = st.at :wiz, :bang
      nils_bohr.should eql( [ nil, nil ] )
    end
  end
end
