require_relative 'test-support'

module Skylab::Permute::TestSupport

  describe "[pe] CLI" do

    extend TS_
    use :expect_CLI

    # INVITE_RX = /try.+permoot.+for help/
    it '0     no args - says expecting / usage / invite' do

      invoke
      expect_expecting_action_line
      expect_usaged_and_invited
    end

    it '1.1   one wrong arg - says invalid action / usage / invite' do

      invoke 'foiple'
      expect_unrecognized_action :foiple
      expect_express_all_known_actions
      expect_generically_invited
    end

    it '0     (under generate cmd) says custom expecting / invite' do

      invoke 'generate'
      expect %r(\bplease provide one or more\b)
      expect_specifically_invited_to :generate
    end

    it "MONEY SHOT - the pipeline complains about ambiguity" do

      using_expect_stdout_stderr_invoke_via_argv(
        %w( generate --county=washtenaw --coint=pariah -c fooz ) )

      expect(
        'ambiguous category letter "c" - did you mean "county" or "coint"?',
      )

      expect_specifically_invited_to :generate
    end

    it "k." do

      using_expect_stdout_stderr_invoke_via_argv(
        %w(generate --flavor vanilla -fchocolate --cone sugar -cwaffle -ccup) )

      _a =  @IO_spy_group_for_expect_stdout_stderr.release_lines

      _act = _a.map( & :string ).join( EMPTY_S_ ).should eql(

      <<-HERE.unindent
        flavor: vanilla
          cone: sugar
        ---
        flavor: chocolate
          cone: sugar
        ---
        flavor: vanilla
          cone: waffle
        ---
        flavor: chocolate
          cone: waffle
        ---
        flavor: vanilla
          cone: cup
        ---
        flavor: chocolate
          cone: cup
        (6 structs total)
      HERE
      )

      @exitstatus.should be_zero
    end
  end
end

# :+#tombstone: was [#ts-010]
