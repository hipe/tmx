require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] core operations - integration with w#{}ip-it", slow: true do  # :[#026].

    # highly experimental - this tests a feature that is (a) housed in a
    # different sidesystem ([ts]) and (b) frontiers features of a facility
    # housed in yet another sidesystem (expression handler in [br]).
    #
    # the reason we test this feature here and not in [ts] is because
    # [ts] is considered more essential than this sidesystem .. (etc) ..
    #
    # to boot, we create a whole (real) repository to test this..
    #
    # since this placement is contrary to convention (and will not be
    # picked up by some coverage testing techniques) we will probably move
    # it..

    TS_[ self ]
    use :memoizer_methods

    context "(context)" do

      shared_subject :_state do

        __write_three_files
        __add_two_files_to_version_control
        __produce_state
      end

      it "succeeds", f: true do
        _state.result == true or fail
      end

      it "one file is skipped because it has unversioned changes" do

        _rx = %r(\Askipping because file changed .+/foo-diddle_spec\.rb\z)
        _state.lines.first =~ _rx or fail
      end

      it "one file is reported as changed" do

        _rx = %r(\Awrote 2 change\(s\) \(\d{2} bytes\) - .+/foo-daddle_spec\.rb\z)
        _state.lines[1] =~ _rx or fail
      end

      it "summary is summary" do

        _s = "(skipped 1 file(s) and made 2 change(s) in 1 file(s).)"
        _state.lines.last == _s or fail
      end

      it "note there was no mention AT ALL of the unversioned file" do
        _state.lines.length == 3 or fail
      end

      it "content looks right (note it is a regex hack)" do

        _ = ::File.read( _state.path_of_file_B )
        _exp = "  describe \"wizzle\", w#{}ip: true do\nsome line\n#{
          }  describe \"xx\", w#{}ip: true do\n"

        _ == _exp or fail
      end

      def __produce_state

        s_a = []
        _y = ::Enumerator::Yielder.new do |s|
          if do_debug
            debug_IO.puts s.inspect
          end
          s_a.push s
        end

        path_of_file_B = ::File.join @_path, @_file_B

        a = []
        a.push ::File.join( @_path, @_file_A )
        a.push path_of_file_B
        _st = Callback_::Stream.via_nonsparse_array a

        guy = TestSupport_::Quickie::Plugins::Wip_It.allocate
        guy.instance_variable_set :@y, _y

        _ok = guy.___via_test_path_stream _st

        sta = _state_struct.new
        sta.result = _ok
        sta.lines = s_a
        sta.path_of_file_B = path_of_file_B
        sta
      end

      dangerous_memoize :_state_struct do

        X_CO_Integ_State = ::Struct.new(
          :result,
          :lines,
          :path_of_file_B,
        )
      end

      def __write_three_files

        sys = Home_.lib_.system

        @_path = ::File.join sys.defaults.dev_tmpdir_path, '[sa]'

        td = sys.filesystem.tmpdir.new_with(
          :path, @_path,
          :be_verbose, do_debug,
          :debug_IO, debug_IO,
          :max_mkdirs, 2,
        )

        td.prepare

        @_file_A = 'foo-diddle_spec.rb'
        @_file_B = 'foo-daddle_spec.rb'
        @_file_C = 'foo-doddle_spec.rb'

        td.write @_file_A, " describe \"wazzoozle\" do\n"

        td.write @_file_B, "  describe \"wizzle\" do\nsome line\n  describe \"xx\" do\n"

        td.write @_file_C, "   describe \"wuzzle\" do\n"

        NIL_
      end

      def __add_two_files_to_version_control

        require 'open3'

        s, o, e, w = ::Open3.popen3 'bash', chdir: @_path

        s.puts 'git init .'

        _here = ::File.join @_path, '.git'
        _line = o.gets
        _rx = %r(\AInitialized empty Git repository in #{ ::Regexp.escape _here })

        _rx =~ _line or fail

        s.puts "git add #{ @_file_A }"
        s.puts "git add #{ @_file_B }"
        # (don't add @_file_C)

        s.puts "git commit -m 'ok'"

        s.puts "echo 'hi' >> #{ @_file_A }"  # add some unversioned change

        s.close

        o.gets =~ %r(\A\[master \(root-commit\) ) or fail

        w.value.exitstatus.zero? or fail

        _s = e.gets
        _s and fail

        NIL_
      end
    end
  end
end
