require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - workspace - `status`" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_CLI_or_API
    use :operations

    context "dir w/o config file - is not failure, result is \"promise\"" do

      it "succeeds" do
        _tuple || fail
      end

      it "result is a debugging sexp" do
        a = _tuple.first
        a.first == :did_not_exist || fail
        ::File.basename( a.last ) == "config.ini" || fail
      end

      it "emits this one event" do

        _ev = _tuple.last

        _lines = black_and_white_lines _ev

        expect_these_lines_in_array_ _lines do |y|
          y << '"tan-man-workspace/config.ini" not found in fixture-directories'
        end
      end

      shared_subject :_tuple do

        call_API :workspace, :status, :path, dirs

        ev = nil
        expect :info, :resource_not_found do |ev_|
          ev = ev_
        end

        _result = execute

        [ _result, ev ]
      end
    end

    context "partay" do

      it "wee" do
        _tuple || fail
      end

      it "result is special tuple" do
        a = _tuple.first
        a.first == :existed || fail
        a.last.include? ::File::SEPARATOR or fail
      end

      it "emits" do
        expect_these_lines_in_array_ _tuple.last do |y|
          y << "resource exists - tan-man.conf"
        end
      end

      shared_subject :_tuple do

        call_API(
          :workspace, :status,
          :path, dir( :with_freshly_initted_conf ),
          :config_filename, 'tan-man.conf',
        )

        lines = nil
        expect :info, :expression, :resource_exists do |y|
          lines = y
        end

        _hi = execute
        [ _hi, lines ]
      end

      def expression_agent
        expression_agent_for_CLI_TM
      end
    end

    # ==
    # ==
  end
end
# #tombstone-B: rewrite during migration away from [br]
# this line is for :+#posterity - "@todo waiting for permute [#056]"
