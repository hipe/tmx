require_relative '../test-support'

module Skylab::SubTree::TestSupport

  describe "[st] modality integration - CLI - canon" do

    TS_[ self ]
    use :CLI, :want_expression

    it "invoke the ping of the API, adapted to this modality" do
      invoke 'ping'
      want :styled, 'hello from sub tree.'
      want_no_more_lines
      expect( @exitstatus ).to eql :hello_from_sub_tree
    end

    it "0   : no args        : expecting / usage / invite" do
      invoke
      want "expecting <action>"
      want :styled, _usage_rx
      _want_generic_invite
    end

    it "1.1 : one unrec arg  : msg / expecting / invite" do
      invoke 'borf'
      want "unrecognized action \"borf\""
      _want_known_actions
      _want_generic_invite
    end

    it "1.2 : one unrec opt  : expecting / invite" do
      invoke '-z'
      want 'invalid option: -z'
      _want_generic_invite
    end

    it "1.3 : one opt : `-h` : usage / invite" do

      invoke '-h'

      big = @IO_spy_group_for_want_stdout_stderr.lines.map do | ln |
        ln.string
      end.join EMPTY_S_

      expect( big ).to match %r(--help \[cmd\][ ]+this screen \(or help for action\))

      expect( big ).to match %r(\bthe point of this\b)

      expect( big ).to match %r(\binspired by unix\b)

      want_success_result
    end

    it "2.1 : `-h unrec`     : msg invite" do

      invoke '-h', 'wat'
      want_unrecognized_action :wat
      _want_known_actions
      _want_generic_invite
    end

    def want_unrecognized_action sym  # #todo
      want :e, "unrecognized action #{ sym.id2name.inspect }"
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

      define_method :_want_generic_invite do
        want generic_help_string
        want_errored_generically
      end


      define_method :_want_known_actions do

        _emmi = @__sout_serr_actual_scanner__.gets_one

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
