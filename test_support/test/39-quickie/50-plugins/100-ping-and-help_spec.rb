require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - plugins - ping and help" do

    TS_[ self ]
    use :memoizer_methods
    use :quickie_plugins

    context "nothing" do

      it "API - whines about not reaching endpoint" do
        call
        expect_these_lines_via_no_transition_found_ do |y|
          write_messages_into_for_no_transition_because_nothing_pending_ y
        end
      end

      it "CLI - whines about not reaching endpoint (STUB)" do
        invoke
        expect_these_lines_on_stderr do |y|
          write_messages_into_for_no_transition_because_nothing_pending_ y
          write_messages_into_for_invite_generically_ y
        end
        expect_fail
      end
    end

    context "strange" do

      it "API - splay" do
        call :wuz_up
        expect :error, :expression, :primary_parse_error, :primary_not_found do |y|
          y[0] == "unknown primary 'wuz_up'" || fail
          y[1] =~ /\Aavailable primaries: '/ || fail
        end
        expect_fail
      end

      it "CLI - splay" do
        invoke '-wuz-up'
        expect_these_lines_on_stderr do |y|
          y << 'unknown primary "-wuz-up"'
          y << %r(\Aavailable primaries: -[a-z])
          write_messages_into_for_invite_generically_ y
        end
        expect_fail
      end
    end

    context "ping" do

      same = "the quickie tree-runner microservice says"

      it "API (symbol result is result of invocation)" do
        call :ping
        expect :info, :expression, :ping do |y|
          y[0] == "#{ same } *hello*" || fail
        end
        expect_result :_ping_from_quickie_tree_runner_microservice_
      end

      it "CLI (symbol result is swallowed by client)" do
        invoke '-ping'
        on_stream :serr
        expect_styled_line "#{ same } ", [ "hello", [:strong, :green] ], [ EMPTY_S_, :no_style ]
        expect_succeed
      end
    end

    context "help" do

      it "API (!)" do

        call :help
        expect :error, :expression, :mode_mismatch do |y|
          y[0] == "no 'help' for API client" || fail
        end
        expect_fail
      end

      context "CLI" do

        it "expresses all lines to stderr" do
          _seen || fail
        end

        it "(fine-grained constituency-check (FRAGILE))" do

          _expected = [
            :cover,
            :depth,
            :doc_only,
            :help,
            :list_files,
            :order,
            :path,
            :run_files,
            :tag,
            :tree,
            :wip_files,
          ]

          seen = _seen ; missing = nil
          _expected.each do |k|
            yes = seen.delete k
            yes or (missing ||= []).push k
          end
          missing and fail "missing: #{ missing.inspect }"
          seen.length.zero? or fail "extra: #{ seen.keys.inspect }"
        end

        # TL;DR: we sneak coverage of fuzzy #here for now. fuzzy resolution
        # deserves its own dedicated test, but we can't use a fuzzy
        # invocation of `ping` because `ping` is hard-coded not to use the
        # operator branch. we could do a dedicated test of `-help` as fuzzy
        # but `-help` is a heavy lift, so building the same (big) help
        # screen twice feels like a waste. we could skip the coverage of
        # fuzzy in this commit but then we can't allow ourselves to commit
        # the changes to the toplevel binfile in this commit, because we
        # cover that file "softly" by using the canonoic `[binfile] -h`
        # invocation and covering that. what we should actually probaby do
        # is give `-ping` its own dedicated file after all but we're not
        # emotionally ready for that now..

        shared_subject :_seen do

          # invoke '-help'
            invoke '-hel'  # per #here #temporary

          on_stream :serr

          # #[#007.B] hand-written #[#ze-054] help screen parser for now

          p = nil

          blank_then = -> p_ do
            p = -> line do
              if ! line.nil?
                fail "expected blank line as nil had #{ line.inspect }"
              end
              p = p_
            end
          end

          rx = /\A[ ]+-(?<slug>[a-z]+(?:-[a-z]+)*)/

          seen = {}
          items = -> line do
            if line
              md = rx.match line
              if md
                k = md[ :slug ].gsub( DASH_, UNDERSCORE_ ).intern
                _already = seen.fetch k do
                  seen[ k ] = true ; false
                end
                _already and fail "collision: #{ md[ :slug ].inspect }"
              end
            end
          end

          primaries = -> line do
            line == "primaries:" || fail
            p = items
          end

          description = -> line do
            line.include? 'description: ' or fail
            blank_then[ primaries ]
          end

          p = -> line do
            line.include? 'usage: zingo fasto { -' or fail
            blank_then[ description ]
          end

          expect_each_by do |line|
            p[ line ]
            NIL
          end

          expect_succeed
          seen
        end
      end
    end

    # ==

    # ==
  end
end
# #born years later
