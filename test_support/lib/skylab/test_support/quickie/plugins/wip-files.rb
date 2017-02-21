module Skylab::TestSupport

  module Quickie

    class Plugins::WipFiles

      # (experimentally this is tested by the dependee library at [#sa-026])
      # (wormhole with [#sa-024])

      def initialize
        o = yield
        @_client_listener = o.listener
        @_shared_datapoint_store = o
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "a search-replace hack: all `describe` blocks in"
        y << "the files that look \"normal\", add a `wip` tag"
        y << "(no dry-run yet, but only mutates unmodified files)"
      end

      def parse_argument_scanner_head
        ACHIEVED_  # it's a flag; nothing to do
      end

      def release_agent_profile
        Eventpoint_::AgentProfile.define do |o|
          o.must_transition_from_to :files_stream, :finished
        end
      end

      def invoke _  # #testpoint (over in [sa])

        st = @_shared_datapoint_store.release_test_file_path_streamer_.call

        __init_vendor_listener
        @_vendor_listener = method :__receive_emission_from_vendor
        __init_skip_listener
        @_skip_listener = method :__receive_emission_from_skip

        @_Search_and_Replace = Autoloader_.require_sidesystem :SearchAndReplace

        sess = Home_.lib_.git.check_SCM::Session.begin( & @_skip_listener ).finish

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

          ok = __replace_the_things_in_this_one_file path
          # (but if something failed here, let's stop for now)
          ok or break

          redo
        end while above

        msg = if ok

          pcs = []
          if @_skip_count.nonzero?
            pcs.push "skipped #{ @_skip_count } file(s)"
          end

          if @_replacement_count.nonzero? || @_edit_session_count.nonzero?
            pcs.push "made #{ @_replacement_count } change(s) in #{
              }#{ @_edit_session_count } file(s)"
          end

          if pcs.length.zero?
            "(did nothing.)"
          else
            "(#{ pcs.join ' and ' }.)"
          end
        else
          "(had errors.)"
        end

        @_client_listener.call :info, :expression, :summary do |y|
          y << msg
        end

        NIL
      end

      def __replace_the_things_in_this_one_file path
        if __thing_one path
          __thing_two
          ACHIEVED_
        end
      end

      def __thing_one path

        # (change `:path` to `:paths` for this to work on multiple files)

        _ = @_Search_and_Replace::API.call(
          :ruby_regexp, RX___,
          :path, path,
          :search,
          :replacement_expression, REPLACEMENT_EXPRESSION___,
          :replace,
          & @_vendor_listener )

        _store :@__custom_stream, _
      end

      def __thing_two
        st = remove_instance_variable :@__custom_stream
        # -
          begin
            es = st.gets  # #tracked [#sa-024] complicated client interface
            es or break
            @_edit_session_count += 1
            mc = es.first_match_controller
            d = 0
            begin
              _ = mc.engage_replacement( & @_vendor_listener )
              _ or self._SANITY
              d += 1
              mc = mc.next_match_controller
            end while mc

            _add_number_of_replacements d

            path_ = es.path

            fh = ::File.open path_, ::File::WRONLY

            es.write_output_lines_into fh do | * chan, & p|
              __express_thing p, chan, d, path_
            end

            fh.close

            redo
          end while above
        # -
        NIL
      end

      def __express_thing p, chan, d, path_

        [ :info, :data, :number_of_bytes_written ] == chan || self._SANITY
        _bytes = p[]

        @_client_listener.call :info, :expression, :rewrote_file do |y|
          y << "wrote #{ d } change(s) (#{ _bytes } bytes) - #{ pth path_ }"
        end
        # (the above is reference in [ze] as [#008.4]
        NIL
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

      def __receive_emission_from_vendor * a, & p
        _treetown p, a, @_vendor_emission_treetown
      end

      def __init_vendor_listener
        # ETC ETC :set_leaf_component  # always ignore these
        # VERBO `grep_command_head`

        @_vendor_emission_treetown = {
          info: {
            expression: {
              grep_command_head: :__maybe_express_grep_command_head,
            },
            event: {
              find_command_args: :__maybe_express_find_command_args,
            },
            set_leaf_component: :__always_ignore_set_leaf_component,
          }
        }
        NIL
      end

      def __maybe_express_find_command_args & p
        # #verbose here
        NIL
      end

      def __maybe_express_grep_command_head & p
        # #verbose here
        NIL
      end

      def __always_ignore_set_leaf_component
        # (these are for zerk iCLI; uninteresting to us)
        NOTHING_
      end

      def __receive_emission_from_skip * a, & p
        _treetown p, a, @_skip_listener_treetown
        NIL
      end

      def __init_skip_listener
        @_skip_listener_treetown = {
          error: {
            expression: :__receive_error_expression_from_skip,
          }
        }
        NIL
      end

      def _treetown p, a, node
        a.each do |sym|
          node = node.fetch sym
        end
        send node, & p
      end

      def __receive_error_expression_from_skip & orig_p

        @_client_listener.call :info, :expression, :skip do |y|
          main = -> line do
            y << line
          end
          p = -> line do
            p = main
            y << "skipping because #{ line }"
          end
          _y = ::Enumerator::Yielder.new do |line|
            p[ line ]
          end
          calculate _y, & orig_p
          y
        end
        NIL
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # ==

        RX___ = /^([ ]+)describe "((?:[^\\"]|\\.)+)" do$/

        REPLACEMENT_EXPRESSION___ = '{{ $1 }}describe "{{ $2 }}", wip: true do'
      # ==
    end
  end
end
# #tombstone-A: "handler expresser"
