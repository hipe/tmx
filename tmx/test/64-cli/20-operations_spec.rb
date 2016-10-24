require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - operations (all \"map\" for now)" do

    TS_[ self ]
    use :CLI
    use :non_interactive_CLI_fail_early

    context "these three distinct cases have the same error message" do

      it "strange primary" do
        _expect_bad_primary '-strange'
      end

      it "non-primary when primary expected (FOR NOW)" do
        _expect_bad_primary 'beepo'
      end

      it "try to access primary that is blacklisted" do
        _expect_bad_primary '-json-file-stream'
      end

      def _expect_bad_primary same
        invoke _subject_operation, same
        expect_on_stderr "unrecognized primary \"#{ same }\""
        expect "expecting { -order | -select }"
        expect_failed_normally_
      end
    end

    define_singleton_method :_given do |s_a|
      define_method :prepare_CLI do |cli|
        _st = TS_::Operations::Map::Dir01::JSON_file_stream_via[ s_a ]
        cli.json_file_stream_by { _st } ; nil
      end
    end

    context "names only, no modifiers" do

      it "works" do
        invoke _subject_operation
        expect_on_stdout 'tyris'
        expect 'deka'
        expect_succeeded
      end

      _given %w( tyris deka )
    end

    context "select one additional attribute" do

      context "when all values non-nil" do

        it "works as expected (note default record separator is a SPACE)" do
          _invoke_same
          expect_on_stdout "damud 44"
          expect "adder 33"
          expect_succeeded
        end

        _given %w( damud adder )
      end

      context "when a value is not present" do

        it "displays a DASH for the value" do
          _invoke_same
          expect_on_stdout "frim_frum -"
          expect_succeeded
        end

        _given %w( frim_frum )
      end

      context "when a value is nil"  # #todo maybe

      def _invoke_same
        invoke _subject_operation, '-select', 'cost'
      end
    end

    if false  # wip: true
    Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ self ]
    use :operations_building
    use :CLI

    it "1.1 strange arg" do

      invoke 'strange'
      expect_unrecognized_action :strange
      expect :styled, :e, /\Aknown actions are \('zorpa-norpa'\)/
      expect_generic_invite_line
      expect_failed
    end

    it "1.3 good arg (full word) - whine about no action" do

      invoke 'zorpa-norpa'
      _when_no_action
    end

    it "1.3 good arg (partial) - whine about no action " do

      invoke 'z'
      _when_no_action
    end

    def _when_no_action

      expect :styled, :e, /\Aexpecting <action>/
      expect :styled, :e, "usage: zizzy zorpa-norpa <action> [..]"
      expect_specifically_invited_to :"zorpa-norpa"
    end

    it "2.3,3 good args (full words) WIN" do

      invoke 'zorpa-norpa', 'shanoozle'
      _same_win
    end

    it "1.3 good arg (partial)" do

      invoke 'zo', 'sha'
      _same_win
    end

    def _same_win

      expect :e, 'wazoozle "YAY"'
      expect_no_more_lines
      @exitstatus.should eql :__shazznastic__
    end

    dangerous_memoize_ :subject_CLI do

      cls = ::Class.new Home_.lib_.brazen::CLI
      TS_::Mo_Fro_Moda_CLI__CLI = cls

      front = _front

      cls.send :define_method, :initialize do | i, o, e, pn_s_a |

        _k = front.to_kernel_adapter

        super i, o, e, pn_s_a, :back_kernel, _k
      end

      cls
    end

    dangerous_memoize_ :_front do  # c.p

      box = Common_::Box.new
      box.add :zorpa_norpa, _unbound_Z

      o = subject_module_.new( & method( :fail ) )
      init_front_with_box_ o, box
      o
    end

    dangerous_memoize_ :_unbound_Z do

      mod = build_mock_unbound_ :Zorpa_Norpa

      TS_::Mo_Fro_Moda_CLI__Unb = mod

      cls = build_shanoozle_into_ mod

      cls.send :define_method, :produce_result do

        @on_event_selectively.call :info, :expression do | y |
          y << "wazoozle #{ ick 'YAY' }"
        end

        :__shazznastic__
      end

      mod
    end
    end  # if false

    def prepare_CLI cli
      cli.json_file_stream_by { X_c_op_explosive_stream[] }
      NIL
    end


    map = 'map'
    define_method :_subject_operation do
      map
    end

    # ==

    X_c_op_explosive_stream = Lazy_.call do
      Common_.stream do
        TS_._EXPLICITLY_EXPECTING_NOT_TO_GET_TO_THE_POINT_OF_LISTING_JSON_FILES
      end
    end

    # ==
  end
end
# #pending-rename: after everything, this is just for the 'map' operation
