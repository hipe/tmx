require_relative '../../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] models - front - modalities - CLI" do

    extend TS_
    use :models_building
    use :modalities_CLI

    it "1.1 strange arg" do

      invoke 'strange'
      expect :styled, :e, /\Aunrecognized action 'strange'/
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

      expect :styled, :e, "wazoozle 'YAY'"
      expect_no_more_lines
      @exitstatus.should eql :__shazznastic__
    end

    dangerous_memoize_ :subject_CLI do

      cls = ::Class.new Home_.lib_.brazen::CLI
      TS_::Mo_Fro_Moda_CLI__CLI = cls

      front = _front

      cls.send :define_method, :expression_agent_class do

        Home_.lib_.brazen::CLI::Expression_Agent
      end

      cls.send :define_singleton_method, :new do | * a |

        _k = front.to_kernel_adapter

        new_top_invocation a, _k
      end

      cls
    end

    dangerous_memoize_ :_front do  # c.p

      box = Callback_::Box.new
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
