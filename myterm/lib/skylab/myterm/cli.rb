module Skylab::MyTerm

  class CLI

    # (currently this is the non-interactive CLI. we want to merge the two)

    # to review, [ze] will "generate" for us (#todo  [#015])
    # we want to leverage the [ze] generated CLI to

    def initialize sin, sout, serr, pn_s_a
      @_FS_qk = nil
      @_SC_qk = nil
      @sin = sin ; @sout = sout ; @serr = serr ; @pn_s_a = pn_s_a
    end

    def filesystem_conduit= x
      @_FS_qk = Common_::Known_Known[ x ] ; x
    end

    def system_conduit= x
      @_SC_qk = Common_::Known_Known[ x ] ; x
    end

    def invoke argv

      if argv.length.zero?

        cli = Here_::Interactive.begin_CLI_
        cli.universal_CLI_resources @sin, @sout, @serr, @pn_s_a
        cli = cli.finish  # (does nothing at writing)

        cli.invoke argv  # argv is empty. result is exitstatus
      else
        __invoke_non_interactive argv
      end
    end

    def __invoke_non_interactive argv

      Require_zerk_[]

      acs = Home_.build_root_ACS_

      if @_FS_qk
        acs.filesystem_knownness = @_FS_qk
      end

      if @_SC_qk
        acs.system_conduit_knownness = @_SC_qk
      end

      cli = Zerk_::NonInteractiveCLI.begin

      cli.compound_custom_sections = -> hf do
        Here_::Custom_::Compound_custom_sections[ hf ]
      end

      cli.compound_usage_strings = -> y, sa do
        Here_::Custom_::Compound_usage_strings[ y, sa ]
      end

      cli.operation_usage_string = -> sa do
        Here_::Custom_::Operation_usage_string[ sa ]
      end

      cli.when_head_argument_looks_like_option = -> do
        Attempt_parse_etc___.new( cli ).execute
      end

      cli.invite = -> ze_invite do
        Here_::Custom_::Invite[ ze_invite ]
      end

      cli.root_ACS_by do  # #cold-model
        acs
      end

      cli.universal_CLI_resources @sin, @sout, @serr, @pn_s_a

      cli.finish

      cli.invoke argv
    end

    class Attempt_parse_etc___

      def initialize cli
        @CLI = cli
      end

      def execute
        if __parse_adapter
          __when_adapter
        elsif __parse_help
          @CLI.when_head_argument_looks_like_help @_md
        else
          _ = "expected -h or -a. had \"#{ @CLI.current_token }\"."
          @CLI.done_because _, :argument
        end
      end
      def __parse_help
        @_md = @CLI.head_token_starting_with_dash_match_help_request
        @_md ? true : false
      end

      def __parse_adapter  # assume starts with dash

        st = @CLI.argument_stream
        s = st.current_token
        md = %r(\A-a([[:alnum:]]+)?\z).match s
        if md
          st.advance_one
          yes = true
          val = md[1]
        else
          md = %r(\A--([a-z-]+)(?:=(.+))?\z).match s
          if md
            nam = md[1]
            if nam == 'adapter'[ 0, nam.length ]
              st.advance_one
              yes = true
              val = md[2]
            end
          end
        end
        if yes
          if ! val
            unless st.no_unparsed_exists
              val = st.gets_one
            end
          end
        end
        if yes
          @_val = val
        end
        yes
      end

      def __when_adapter

        _ACS = @CLI.top_frame.ACS

        ok = Call_.call [ :adapter, @_val ], _ACS do |_|
          @CLI.on_event_selectively
        end

        if ok
          ACHIEVED_  # loop again [#009] experiment
        else
          @CLI.init_exitstatus_for_ :referent_not_found  # #todo
          ok
        end
      end
    end

    Here_ = self
  end
end
