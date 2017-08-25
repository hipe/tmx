require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] CLI - deliterate", wip: true do

    TS_[ self ]
    use :memoizer_methods
    use :CLI

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

      expect :styled, :e, /\Afailed because no such <file> - /
      expect_specifically_invited_to :deliterate
    end

    it "money" do

      _path = Fixture_file_[ '01-some-code.code' ]

      invoke 'deliterate', '3', '5', _path

      expect :o, "    def normalize_range"
      expect :o, EMPTY_S_
      expect :o, "      if @to_line < @from_line"
      expect :e, "for example, you could deliterate these lines."
      expect_succeed
    end
  end
end
