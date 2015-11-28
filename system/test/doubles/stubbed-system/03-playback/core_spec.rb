require_relative '../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] doubles - stubbed-system - 03: playback" do

    TS_[ self ]
    use :doubles_stubbed_system

    it "a mock system conduit is built with a pathname (any string)" do

      subject_::Conduit.new _no_ent_path

    end

    it "doesn't read the FS until it is used" do

      _cond = subject_::Conduit.new( _no_ent_path )
      begin
        _cond.popen3 'no'
      rescue ::Errno::ENOENT => e
      end

      e or fail
    end

    it "OK (note STDIN mock is never created, other are IFF present)" do

      cond = subject_::Conduit.new( _manifest_A )
      i, o, e, w = cond.popen3 'echo', "it's", '"fun"'

      i.should be_nil

      o.gets.should eql "it's \"fun\"\n"
      o.gets.should be_nil

      e.should be_nil

      w.value.exitstatus.should be_zero
    end

    memoize :_no_ent_path do

      TS_.dir_pathname.join( 'no-ent' ).to_path
    end

    dangerous_memoize :_manifest_A do

      path_for_ '03-playback/fixtures/story-A.ogdl'
    end
  end
end
