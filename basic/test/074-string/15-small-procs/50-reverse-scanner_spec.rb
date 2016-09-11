require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - small procs - reverse scanner" do

    extend TS_
    use :string

    it "abs 2" do

      scn = _build "XoneXtwo", 'X'.getbyte( 0 )
      _ = scn.gets
      _.should eql "two"
      _ = scn.gets
      _.should eql "one"
      _ = scn.gets
      _.should eql EMPTY_S_
      _ = scn.gets
      _.should be_nil
      _ = scn.gets
      _.should be_nil
    end

    _DOT_BYTE = '.'.getbyte 0

    it "rel 1" do

      scn = _build 'hi', _DOT_BYTE
      _ = scn.gets
      _.should eql 'hi'
      _ = scn.gets
      _.should be_nil
      scn.gets.should be_nil
    end

    it "rel 2" do

      scn = _build 'a.b', _DOT_BYTE
      scn.gets.should eql 'b'
      scn.gets.should eql 'a'
      scn.gets.should be_nil
      scn.gets.should be_nil
    end

    it "rel 1 (trail)" do

      scn = _build 'a.b.', _DOT_BYTE
      _ = scn.gets
      _.should eql EMPTY_S_
      _ = scn.gets
      _.should eql 'b'
      scn.gets.should eql 'a'
      scn.gets.should be_nil
      scn.gets.should be_nil
    end

    it "empty s" do
      _s_a = _split EMPTY_S_
      _s_a.length.should be_zero
    end

    it "only sep (acts like `String#split( s, -1 )`)" do
      _s_a = _split '.'
      _s_a.should eql [ EMPTY_S_, EMPTY_S_ ]
    end

    it "(etc)" do
      _s_a = _split '..'
      _s_a.should eql [ EMPTY_S_, EMPTY_S_, EMPTY_S_ ]
    end

    define_method :_split do | str |
      s_a = []
      scn = _build str, _DOT_BYTE
      begin
        s = scn.gets
        s or break
        s_a.push s
        redo
      end while nil
      s_a
    end

    def _build str, byte
      subject_module_.reverse_scanner str, byte
    end
  end
end
