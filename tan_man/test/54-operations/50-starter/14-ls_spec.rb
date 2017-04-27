require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - starter list" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_CLI_or_API
    use :operations

    context "(ok)" do

      it "produces a result" do
        _result || fail
      end

      it "the result (a stream) has every item in the pool of expected items" do
        _missing_and_extra.first.length.zero? || fail
      end

      it "the result (a stream) doesn't have any items outside of the expected items" do
        _missing_and_extra.last && fail
      end

      # ===

      shared_subject :_missing_and_extra do

        # (:#spot1.2: tests at or near having a dependency on the below constituency)

        extra = nil

        pool = {
          "digraph.dot" => true,
          "holy-smack.dot" => true,
          "minimal.dot" => true,
          "shorty-short.dot" => true,
        }

        st = _result
        begin
          item = st.gets
          item || break
          _had = pool.delete item.natural_key_string
          _had && redo
          ( extra ||= [] ).push item
          redo
        end while above

        [ pool, extra ]
      end

      # ===

      shared_subject :_result do

        call_API(
          :starter, :ls,
        )

        execute
      end
    end
  end
end
# #history-A: full rewrite during [br] ween
