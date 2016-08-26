module Skylab::TestSupport

  module Quickie

    class Plugins::Wip_It

      # (experimentally this is tested by the dependee library at [#sa-026])
      # (wormhole with [#sa-024])

      def initialize adapter
        @fuzzy_flag = adapter.build_fuzzy_flag %w( -wip-them-all )
        @adapter = adapter
      end

      def opts_moniker
        @fuzzy_flag.some_opts_moniker
      end

      def args_moniker
      end

      def desc y
        y << "a search-replace hack: all `describe` blocks in"
        y << "the files that look \"normal\", add a `wip` tag"
        y << "(no dry-run yet, but only mutates unmodified files)"
      end

      def prepare sig
        idx = @fuzzy_flag.any_first_index_in_input sig
        if idx
          sig.nilify_input_element_at_index idx
          sig.rely :CULLED_TEST_FILES
          sig.carry :CULLED_TEST_FILES, :FINISHED
          sig
        end
      end

      def culled_test_files_eventpoint_notify

        @y = @adapter.y
        ___via_test_path_stream @adapter.services.to_test_path_stream
        NIL_  # for now, ignore any failure from above..
      end

      def ___via_test_path_stream st  # #testpoint

        __define_constants

        __init_emission_handlers

        @_Search_and_Replace = Autoloader_.require_sidesystem :SearchAndReplace

        sess = Home_.lib_.git.check_SCM::Session.begin( & @_skip_oes_p ).finish

        __init_counters

        ok = true
        begin
          path = st.gets
          path or break

          _ok_ = sess.check path
          if ! _ok_
            # even if one file can't be changed, keep going
            @_skip_count += 1
            redo
          end

          ok = ___replace_the_things_in_this_one_file path
          # (but if something failed here, let's stop for now)
          ok or break

          redo
        end while nil

        if ok

          pcs = []
          if @_skip_count.nonzero?
            pcs.push "skipped #{ @_skip_count } file(s)"
          end

          if @_replacement_count.nonzero? || @_edit_session_count.nonzero?
            pcs.push "made #{ @_replacement_count } change(s) in #{
              }#{ @_edit_session_count } file(s)"
          end

          if pcs.length.zero?
            @y << "(did nothing.)"
          else
            @y << "(#{ pcs.join ' and ' }.)"
          end
        else
          @y << "(had errors.)"
        end

        ok
      end

      def ___replace_the_things_in_this_one_file path

        # (change `:path` to `:paths` for this to work on multiple files)

        st = @_Search_and_Replace::API.call(
          :ruby_regexp, RX___,
          :path, path,
          :search,
          :replacement_expression, REPLACEMENT_EXPRESSION___,
          :replace,
          & @_vendor_oes_p )

        if st  # #tracked [#sa-024] complicated client interface
          begin
            es = st.gets
            es or break
            @_edit_session_count += 1
            mc = es.first_match_controller
            d = 0
            begin
              _ = mc.engage_replacement( & @_vendor_oes_p )
              _ or self._SANITY
              d += 1
              mc = mc.next_match_controller
            end while mc

            _add_number_of_replacements d

            path_ = es.path

            fh = ::File.open path_, ::File::WRONLY

            es.write_output_lines_into fh do | * _, & ev_p |
              _bytes = ev_p[]
              @_oes_p.call :_, :expression do |y|
                y << "wrote #{ d } change(s) (#{ _bytes } bytes) - #{ path_ }"
              end
            end

            fh.close

            redo
          end while nil
          ACHIEVED_
        else
          st
        end
      end

      def __init_counters
        @_edit_session_count = 0
        @_replacement_count = 0
        @_skip_count = 0
        NIL_
      end

      def _add_number_of_replacements d
        @_replacement_count += d
      end

      def __init_emission_handlers

        @_vendor_oes_p = -> * a, & p do
          ( @__ves ||= __build_vendor_emission_handler ).handle a, & p
        end

        @_skip_oes_p = -> * a, & p do
          ( @__seh ||= __build_skip_emission_handler ).handle a, & p
        end

        @_oes_p = -> * a, & p do
          ( @___geh ||= __build_generic_emission_handler ).handle a, & p
        end
      end

      def __build_vendor_emission_handler

        he = _begin_handler_expresser

        he.ignore_emissions_ending_with :set_leaf_component

        # :#here - verbose would go here

        he.maybe_ignore_emissions_ending_with :grep_command_head do
          false  # #here
        end

        he.maybe_ignore_emissions_starting_with :info, :event, :find_command_args do
          false  # #here
        end

        he.finish
      end

      def __build_skip_emission_handler
        he = _begin_handler_expresser
        he.prefix_first_expression_lines_with "skipping because "
        he.finish
      end

      def __build_generic_emission_handler
        _begin_handler_expresser.finish
      end

      def _begin_handler_expresser
        he = CLI_support_[]::Expression_Agent.instance.begin_handler_expresser
        he.downstream_yielder = @y
        he
      end

      yes = true ; go = -> do
        yes = false

        RX___ = /^([ ]+)describe "((?:[^\\"]|\\.)+)" do$/

        REPLACEMENT_EXPRESSION___ = '{{ $1 }}describe "{{ $2 }}", wip: true do'
      end

      define_method :__define_constants do
        yes && go[]
      end
    end
  end
end
