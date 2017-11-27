require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - small procs - reverse scanner" do

    TS_[ self ]
    use :string

    it "abs 2" do

      scn = _build "XoneXtwo", 'X'.getbyte( 0 )
      _ = scn.gets
      expect( _ ).to eql "two"
      _ = scn.gets
      expect( _ ).to eql "one"
      _ = scn.gets
      expect( _ ).to eql EMPTY_S_
      _ = scn.gets
      expect( _ ).to be_nil
      _ = scn.gets
      expect( _ ).to be_nil
    end

    _DOT_BYTE = '.'.getbyte 0

    it "rel 1" do

      scn = _build 'hi', _DOT_BYTE
      _ = scn.gets
      expect( _ ).to eql 'hi'
      _ = scn.gets
      expect( _ ).to be_nil
      expect( scn.gets ).to be_nil
    end

    it "rel 2" do

      scn = _build 'a.b', _DOT_BYTE
      expect( scn.gets ).to eql 'b'
      expect( scn.gets ).to eql 'a'
      expect( scn.gets ).to be_nil
      expect( scn.gets ).to be_nil
    end

    it "rel 1 (trail)" do

      scn = _build 'a.b.', _DOT_BYTE
      _ = scn.gets
      expect( _ ).to eql EMPTY_S_
      _ = scn.gets
      expect( _ ).to eql 'b'
      expect( scn.gets ).to eql 'a'
      expect( scn.gets ).to be_nil
      expect( scn.gets ).to be_nil
    end

    it "empty s" do
      _s_a = _split EMPTY_S_
      expect( _s_a.length ).to be_zero
    end

    it "only sep (acts like `String#split( s, -1 )`)" do
      _s_a = _split '.'
      expect( _s_a ).to eql [ EMPTY_S_, EMPTY_S_ ]
    end

    it "(etc)" do
      _s_a = _split '..'
      expect( _s_a ).to eql [ EMPTY_S_, EMPTY_S_, EMPTY_S_ ]
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
