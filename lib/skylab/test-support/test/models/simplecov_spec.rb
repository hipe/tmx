require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Models

  describe "[ts] models - simplecov" do

    extend TS__

    it "SO BEAUTIFUL / SO UGLY : test simplecov CLI integration in a #sub-process" do

      _exe = "#{
        ::File.dirname( ::File.dirname ::Skylab.dir_pathname.to_path )
      }/bin/tmx-test-support"

      _exe_ = TestSupport_.dir_pathname.join(
        'test/executable-fixtures/for-simplecov.rb'
      ).to_path

      sys = TestSupport_.lib_.system

      _path = sys.defaults.dev_tmpdir_pathname.join( '[ts]' ).to_path

      tmpdir = sys.filesystem.tmpdir :path, _path,
        :be_verbose, do_debug, :debug_IO, debug_IO

      tmpdir.prepare

      _i, o, e, w = TestSupport_::Library_::Open3.popen3(

        _exe, 'cover', 'for-simplec', '--', _exe_, chdir: tmpdir.path )

      o.gets.should match %r(\ACoverage report generated for for-simplecov\.rb)

      o.gets.should be_nil

      line = e.gets
      if line.include? 'warning: possibly useless use of a variable'
        # because simplecov
        line = e.gets
      end

      e.gets.should be_include '{ orange | blue }'

      e.gets.should be_nil

      w.value.exitstatus.should be_zero

      tmpdir.UNLINK_FILES_RECURSIVELY_

    end
  end
end
