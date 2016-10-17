require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - operations" do

    TS_[ self ]

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
  end
end
