require_relative '../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] doubles - stubbed-system - 03: playback" do

    TS_[ self ]
    use :doubles_stubbed_system

    it "a mock system conduit is built with a pathname (any string)" do

      conduit_for_RW_.new the_no_ent_directory_
    end

    it "doesn't read the FS until it is used" do

      _cond = conduit_for_RW_.new the_no_ent_directory_
      begin
        _cond.popen3 'no'
      rescue ::Errno::ENOENT => e
      end

      e or fail
    end

    it "OK (note STDIN mock is never created, other are IFF present)" do

      _manifest_A = fixture_file_ 'ogdl-commands.03.ogdl'

      cond = conduit_for_RW_.new( _manifest_A )

      i, o, e, w = cond.popen3 'echo', "it's", '"fun"'

      expect( i ).to be_nil

      expect( o.gets ).to eql "it's \"fun\"\n"
      expect( o.gets ).to be_nil

      expect( e ).to be_nil

      expect( w.value.exitstatus ).to be_zero
    end

    # ==
    # ==
  end
end
