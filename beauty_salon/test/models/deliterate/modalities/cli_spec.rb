require_relative '../../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] models - delit - modalities - CLI" do

    extend TS_
    use :memoizer_methods
    use :modality_integrations_CLI_support

    context "help" do

      shared_subject :state_ do

        invoke 'deliterate', '-h'
        flush_invocation_to_help_screen_oriented_state
      end

      it "succeeds" do
        state_.exitstatus.should match_successful_exitstatus
      end

      it "the children" do

        _ = state_.tree.children.last.children.reduce [] do | m, node |

          m << node.x.get_column_A_content
        end

        _.should eql %w( <from-line> <to-line> <file> )
      end
    end

    it "no ent" do

      _path = TestSupport_::Fixtures.file( :not_here )

      invoke 'deliterate', '1', '2', _path

      expect :styled, :e, /\Ano such <file> - /
      expect_specifically_invited_to :deliterate
    end

    it "money" do

      _path = __fixture_file '01-some-code.code'

      invoke 'deliterate', '3', '5', _path

      expect :o, "    def normalize_range"
      expect :o, EMPTY_S_
      expect :o, "      if @to_line < @from_line"
      expect :e, "for example, you could deliterate these lines."
      expect_succeeded
    end

    def __fixture_file s

      ::File.join(
        TS_.dir_pathname.to_path,
        'models/deliterate/fixture-files',
        s )
    end
  end
end
