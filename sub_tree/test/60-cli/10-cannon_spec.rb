require_relative '../../test-support'

module Skylab::SubTree::TestSupport

  describe "[st] modality integration - CLI - canon" do

    TS_[ self ]
    use :modality_integrations_CLI, :expect_expression

    define_method :expect, instance_method( :expect )  # #because-rspec

    it "invoke the ping of the API, adapted to this modality" do
      invoke 'ping'
      expect :styled, 'hello from sub tree.'
      expect_no_more_lines
      @exitstatus.should eql :hello_from_sub_tree
    end

    it "0   : no args        : expecting / usage / invite" do
      invoke
      expect "expecting <action>"
      expect :styled, _usage_rx
      _expect_generic_invite
    end

    it "1.1 : one unrec arg  : msg / expecting / invite" do
      invoke 'borf'
      expect "unrecognized action \"borf\""
      _expect_known_actions
      _expect_generic_invite
    end

    it "1.2 : one unrec opt  : expecting / invite" do
      invoke '-z'
      expect 'invalid option: -z'
      _expect_generic_invite
    end

    it "1.3 : one opt : `-h` : usage / invite" do

      invoke '-h'

      big = @IO_spy_group_for_expect_stdout_stderr.lines.map do | ln |
        ln.string
      end.join EMPTY_S_

      big.should match %r(--help \[cmd\][ ]+this screen \(or help for action\))

      big.should match %r(\bthe point of this\b)

      big.should match %r(\binspired by unix\b)

      expect_success_result
    end

    it "2.1 : `-h unrec`     : msg invite" do

      invoke '-h', 'wat'
      expect_unrecognized_action :wat
      _expect_known_actions
      _expect_generic_invite
    end

    def expect_unrecognized_action sym  # #todo
      expect :e, "unrecognized action #{ sym.id2name.inspect }"
    end

    -> do

      all_possible_actions = %w( dirstat files ping )
      cmd_name = 'stcli'

      # ~

      usage_rx = /\Ausage: #{ cmd_name } <action> \[\.\.\]$/

      define_method :_usage_rx do
        usage_rx
      end


      generic_help_string = "use '#{ cmd_name } -h' for help"

      define_method :_expect_generic_invite do
        expect generic_help_string
        expect_errored_generically
      end


      define_method :_expect_known_actions do

        _emmi = @__sout_serr_actual_stream__.gets_one

        _md = %r(\Aknown actions are \((.+)\)$).match _emmi.string

        _s_a = _md[ 1 ].split(', ').map { |s| s[ 1 ... -1 ] }  # unquote. eew

        miss_a = all_possible_actions - _s_a

        if miss_a.length.nonzero?
          fail "missing: #{ miss_a.inspect }"
        end
      end
    end.call
  end
end
