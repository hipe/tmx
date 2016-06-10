require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] operations - simplecov" do

    it "SO BEAUTIFUL / SO UGLY : test simplecov CLI integration in a #sub-process", wip: true do  # #old-wip:2015-10

      self._HEY_this_is_WIPPED_until_simplecov_is_back

      _exe = ::File.join Home_.my_bin_path, 'tmx-test-support'

      _exe_ = ::File.join(
        Home_.my_test_path, 'fixture-executables/for-simplecov.rb' )

      sys = Home_.lib_.system

      _path = ::File.join sys.defaults.dev_tmpdir_path, '[ts]'

      tmpdir = sys.filesystem.tmpdir :path, _path,
        :be_verbose, do_debug, :debug_IO, debug_IO

      tmpdir.prepare

      command_a = [
        _exe, 'cover', 'for-simplec', '--', _exe_
      ]
      command_h = {
        chdir: tmpdir.path }

      _i, o, e, w = Home_::Library_::Open3.popen3(
        * command_a, command_h )

      s = o.gets

      if s
        __expect_success s, o, e, w
      else
        __explain_failure e, w, command_a, command_h
      end

      tmpdir.UNLINK_FILES_RECURSIVELY_
    end

    def __expect_success s, o, e, w

      s.should match %r(\ACoverage report generated for for-simplecov\.rb)

      o.gets.should be_nil

      line = e.gets
      if line.include? 'warning: possibly useless use of a variable'
        # because simplecov
        line = e.gets
      end

      e.gets.should be_include '{ orange | blue }'

      e.gets.should eql "(exitstatus: 0)\n"

      e.gets.should be_nil

      w.value.exitstatus.should be_zero
    end

    def __explain_failure e, w, command_a, command_w

      io = debug_IO

      io.puts "from command #{ command_a.inspect } #{ command_w.inspect }"

      d = w.value.exitstatus
      d.should eql 0
      io.puts "\n\n<< here is hopefully the stacktrace to the above issue:"
      begin
        s = e.gets
        s or break
        s.chomp!
        io.puts "(#{ s } )"
        redo
      end while nil
      io.puts ">>\n\n\n"
      nil
    end
  end
end
