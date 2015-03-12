require_relative '../../test-support'

module Skylab::GitViz::TestSupport::Test_Lib

  describe "[gv] test-lib - mock-sys - playback" do

    it "a mock system conduit is built with a pathname (any string)" do

      subject::Conduit.new _no_ent_path

    end

    it "doesn't read the FS until it is used" do

      _cond = subject::Conduit.new( _no_ent_path )
      begin
        _cond.popen3 'no'
      rescue ::Errno::ENOENT => e
      end

      e or fail
    end

    it "OK (note STDIN mock is never created, other are IFF present)" do

      cond = subject::Conduit.new( _manifest_A )
      i, o, e, w = cond.popen3 'echo', "it's", '"fun"'

      i.should be_nil

      o.gets.should eql "it's \"fun\"\n"
      o.gets.should be_nil

      e.should be_nil

      w.value.exitstatus.should be_zero
    end

    define_method :_no_ent_path, ( Callback_.memoize do
      TS_.dir_pathname.join( 'no-ent' ).to_path
    end )

    define_method :_manifest_A, ( Callback_.memoize do
      TS_.dir_pathname.join( 'mock-sys/03-playback/fixtures/story-A.ogdl' ).to_path
    end )

    def subject
      GitViz_::Test_Lib_::Mock_Sys
    end
  end
end
