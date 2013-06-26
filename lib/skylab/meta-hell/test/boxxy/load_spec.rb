require_relative 'test-support'

module ::Skylab::MetaHell::TestSupport::Boxxy

  describe "#{ MetaHell::Boxxy } load" do

    it "fetching the same nerk twice does not fail" do # catch an edge case
      mod = TS_::Fixtures::Neeples
      mod.const_fetch :line_count
      mod.const_fetch :line_count
    end
  end


  describe "#{ MetaHell::Boxxy } constants / each" do

    it "works, corrects self, doesn't molest immediate values" do
      mod = TS_::Fixtures::Nerples
      a = mod.boxxy_original_constants
      a.length.should eql( 1 )
      b = mod.constants
      b.length.should eql( 2 )
      b.last.should eql( :Fief_Deef )  # the casing of the constant is "wrong"
      c = [] ; d = []
      mod.each.reduce nil do |m, (k, x)|
        c << k
        d << x
        nil
      end
      ( a.object_id == b.object_id ).should eql( false )
      b.last.should eql( :Fief_Deef )
      c.last.should eql( :Fief_DEEf ) # <-- wow! name was corrected
      d.first.should eql( :ferffle_derffle ) # <-- need not be a module
      d.last.should be_kind_of( ::Module )
      d.last.name.index( 'Nerples::Fief_DEEf' ).nil?.should eql( false )
    end
  end
end
