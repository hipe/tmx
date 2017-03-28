module Skylab::SearchAndReplace

  module CLI

    class NonInteractiveViewEffecters::Replace_All_in_File

      # may become dual-purpose - imagine using it in [ts] at our [#024]

      class << self

        def via__ es, cli

          # kind of nasty but we exploit the fact that the above CLI is
          # only (and exactly) as long-running as the "shared session".
          # it's either this or the [ze] "express result" API gets a lot
          # more complicated so that items in a stream can share resources.

          h = cli.top_frame.all_purpose_cache

          _ss = h.fetch KEY__ do
            h[ KEY__ ] = Shared_Session___.__via_CLI( cli )
          end

          new es, _ss
        end

        private :new
      end  # >>

      KEY__ = :_sa_shared_session_  # name shouldn't matter, this is our n.s

      def initialize es, ss
        @edit_session = es
        @_oes_p = ss.on_event_selectively
        @shared_session = ss
      end

      def execute_for es
        dup.___execute_for es
      end

      def ___execute_for es
        @edit_session = es
        execute
      end

      def execute

        ok = __engage_all_replacements
        ok &&= __make_sure_that_file_is_backed_up
        ok &&= __write_file

        if ok
          @shared_session.receive_did_succeed
        else
          @shared_session.receive_did_fail
        end

        NIL_
      end

      def __engage_all_replacements

        d = 0

        mc = @edit_session.first_match_controller
          # (having a file with no match (controller) is #spot-8 #not-covered)

        ok = true
        while mc
          ok = mc.engage_replacement( & @_oes_p )
          ok or break
          d += 1
          mc = mc.next_match_controller
        end

        if ok
          @__replacement_count = d
        end

        ok
      end

      def __make_sure_that_file_is_backed_up

        @shared_session.__check @edit_session.path
      end

      def __write_file

        d = @__replacement_count
        path = @edit_session.path

        is_dry = @edit_session.is_dry_run

        if is_dry
          fh = Home_.lib_.system_lib::IO::DRY_STUB
        else
          fh = ::File.open path, ::File::WRONLY
        end

        data_proc = nil
        @edit_session.write_output_lines_into fh do | * _, & data_p |
          data_proc = data_p
        end
        bytesize = data_proc[]

        fh.truncate bytesize  # as covered by #spot-9

        @_oes_p.call :_, :expression do |y|

          y << "wrote #{ d } change#{ s d } #{
            }(#{ bytesize }#{ ' dry' if is_dry } byte#{ s bytesize }) - #{ pth path }"
        end

        fh.close

        ACHIEVED_
      end

      # ==

      class Shared_Session___

        class << self

          def __via_CLI cli

            he = cli.begin_niCLI_handler_expresser

            vendor_he = he.dup

            vendor_he.prefix_first_expression_lines_with "skipping because "

            he.finish
            vendor_he.finish

            o = new

            o.checker_handler_expresser = vendor_he

            o.handler_expresser = he

            o.on_success = -> do
              cli.maybe_upgrade_exitstatus 0
            end

            o.on_failure = -> do
              cli.maybe_upgrade_exitstatus_for :component_rejected_request
            end

            o.system_conduit = cli.system_conduit

            o
          end

          private :new
        end  # >>

        def initialize
          @on_failure = nil
          @on_success = nil
        end

        attr_writer(  # only during construction, optional
          :checker_handler_expresser,
          :handler_expresser,
          :on_failure,
          :on_success,
          :system_conduit,
        )

        def __check path

          _ = ( @___checker ||= ___build_checker )
          __ = _.check path
          __
        end

        def ___build_checker

          _oes_p = @checker_handler_expresser.on_event_selectively

          o = Home_.lib_.git.check_SCM::Session.begin( & _oes_p )

          o.system_conduit = @system_conduit

          o.finish
        end

        def receive_did_fail
          @on_failure && @on_failure[] ; nil
        end

        def receive_did_succeed
          @on_success && @on_success[] ; nil
        end

        def on_event_selectively

          # for edit session - e.g will be used to display summary info
          # and any errors when replacing.

          @handler_expresser.on_event_selectively
        end
      end

      # ==

      UNRELIABLE_ = :_sa_unreliable_
    end
  end
end
