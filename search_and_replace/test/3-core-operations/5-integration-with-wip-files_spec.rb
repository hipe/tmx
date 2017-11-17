require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] core operations - integration with w#{}ip-files", slow: true do

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
    Common_.test_support::Want_Emission_Fail_Early[ self ]

    context "(context)" do

      shared_subject :_state do

        @TMPDIR = build_my_tmpdir_controller_

        __init_paths

        # (when developing you might want to comment out some lines selectively:)
        __write_three_files
        __add_two_files_to_version_control

        x = __BIG_state
        remove_instance_variable :@TMPDIR
        x
      end

      it "successful result is nil (it's all side-effects)" do
        _state.result.nil? || fail
      end

      it "one file is skipped because it has unversioned changes" do

        y = _state.skip_messages
        y.length == 1 || fail
        y[0] =~ %r(\Askipping because file changed since index \([^\)]+\) - #{
          }\(path\[sa\]:.+/foo-diddle_spec\.rb\)\z) || fail
      end

      it "one file is reported as changed" do

        y = _state.rewrote_messages
        y.length == 1 || fail
        y[0] =~ %r(\Awrote 2 change\(s\) \(\d{2} bytes\) - #{
          }\(path\[sa\]: .+/foo-daddle_spec\.rb\)\z) || fail
      end

      it "summary is summary" do

        y = _state.summary_messages
        y.length == 1 || fail
        y[0] == "(skipped 1 file(s) and made 2 change(s) in 1 file(s).)" || fail
      end

      it "content looks right (note it is a regex hack)" do

        _path = _state.the_path_of_the_file_that_changed

        _big_string = ::File.read _path

        _exp = "  describe \"wizzle\", w#{}ip: true do\nsome line\n#{
          }  describe \"xx\", w#{}ip: true do\n"

        _big_string == _exp || fail
      end

      it "here's a bunch of details about things called" do

        o = _state
        o.seen_find_command_args == 1 || fail
        o.seen_grep_command_head == 1 || fail
        o.seen_set_leaf_component == 3 || fail
      end

      def __BIG_state

        _listener = want_emission_fail_early_listener

        _stubbed_microservice = X_co_integ_StubbedMicroservice.define do |o|
          o.listener = _listener
          o.release_test_file_path_streamer_ = __stub_path_stream
        end

        pi = TestSupport_::Quickie::Plugins::WipFiles.new do
          _stubbed_microservice
        end

        o = X_co_integ_BigState.new

        o.the_path_of_the_file_that_changed = remove_instance_variable :@_path_of_file_B

        want :info, :expression, :skip do |y|
          o.skip_messages = y
        end

        want :info, :expression, :rewrote_file do |y|
          o.rewrote_messages = y
        end

        want :info, :expression, :summary do |y|
          o.summary_messages = y
        end

        pi.send :define_singleton_method, :__maybe_express_find_command_args do
          o.seen_find_command_args += 1
        end
        o.seen_find_command_args = 0

        pi.send :define_singleton_method, :__maybe_express_grep_command_head do
          o.seen_grep_command_head += 1
        end
        o.seen_grep_command_head = 0

        pi.send :define_singleton_method, :__always_ignore_set_leaf_component do
          o.seen_set_leaf_component += 1
        end
        o.seen_set_leaf_component = 0

        call_by do
          pi.invoke :_no_see_SA_
        end

        o.result = execute
        o
      end

      def __stub_path_stream
        paths = []
        paths.push ::File.join( @_path, @_file_A )
        paths.push @_path_of_file_B
        st = Stream_[ paths ]
        once = -> { once = nil ; st }
        -> { once[] }
      end

      def __init_paths
        td = @TMPDIR
        @_path = td.path
        @_file_A = 'foo-diddle_spec.rb'
        @_file_B = 'foo-daddle_spec.rb'
        @_file_C = 'foo-doddle_spec.rb'

        @_path_of_file_B = ::File.join @_path, @_file_B
        NIL
      end

      def __write_three_files

        td = @TMPDIR

        td.prepare

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

    def expression_agent
      X_co_integ_Expag.instance
    end

    # ==

    X_co_integ_BigState = ::Struct.new(
      :result,
      :rewrote_messages,
      :skip_messages,
      :seen_find_command_args,
      :seen_grep_command_head,
      :seen_set_leaf_component,
      :summary_messages,
      :the_path_of_the_file_that_changed,
    )

    # ==

    class X_co_integ_StubbedMicroservice < Common_::SimpleModel

      attr_accessor(
        :listener,
        :release_test_file_path_streamer_,
      )

      def argument_scanner_narrator
        :_no_argument_scanner_narrator_SA
      end
    end

    # ==

    class X_co_integ_Expag
      class << self
        def instance ; @___instance ||= new end
      end  # >>
      alias_method :calculate, :instance_exec
      def pth path
        "(path[sa]: #{ path })"
      end
    end

    # ==
  end
end
