module Skylab::TestSupport

  module Quickie

    class Plugins::Wip_It

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

        @pwd = ::Dir.pwd
        @y = @adapter.y

        ok = __resolve_first_path
        ok &&= __via_first_path_resolve_VCS_session
        ok && __via_VCS_session
      end

      def __resolve_first_path

        @st = @adapter.services.to_test_path_stream
        @first_path = @st.gets
        @first_path && ACHIEVED_
      end

      def __via_first_path_resolve_VCS_session
        @sess = VCS_Session____.via_path ::File.expand_path @first_path, @pwd
        @sess && ACHIEVED_
      end

      def __via_VCS_session

        @_white = []
        path = @first_path
        begin
          ___categorize_path path
          path = @st.gets
          path or break
          redo
        end while nil
        if @_white.length.zero?
          @y << "(nothing to do.)"
        else
          __work remove_instance_variable :@_white
        end
      end

      def ___categorize_path path

        stat = @sess.VCS_stat ::File.expand_path path, @pwd
        if stat
          if stat.is_modified
            @y << "won't modify already modified file, skipping: #{ path }"
          else
            @_white.push path
          end
        else
          @y << "not tracked by #{ @sess.base_name_string }, skipping: #{ path }"
        end
        NIL_
      end

      def __work paths

        _RX = /^([ ]+)describe "((?:[^\\"]|\\.)+)" do$/

        _repl = '{{ $1 }}describe "{{ $2 }}", wip: true do'

        he = nil
        init_handler_expresser = -> do
          he = Home_.lib_.brazen::CLI_Support::Expression_Agent.instance.begin_handler_expresser
          he.downstream_yielder = @y
          he.ignore_ending_with :set_leaf_component ; nil
        end

        oes_p = -> * i_a, & ev_p do
          he || init_handler_expresser[]
          he.handle i_a, & ev_p
        end

        _sa = Autoloader_.require_sidesystem :SearchAndReplace

        st = _sa::API.call(
          :ruby_regexp, _RX,
          :paths, paths,
          :search,
          :replacement_expression, _repl,
          :replace,
          & oes_p )

        count = 0
        if st  # #tracked [#sa-024] complicated client interface
          begin
            es = st.gets
            es or break
            count += 1
            mc = es.first_match_controller
            d = 0
            begin
              _ = mc.engage_replacement( & oes_p )
              _ or self._SANITY
              d += 1
              mc = mc.next_match_controller
            end while mc

            path = es.path

            fh = ::File.open path, ::File::WRONLY

            es.write_output_lines_into fh do | * _, & ev_p |
              _bytes = ev_p[]
              oes_p.call :_, :expression do |y|
                y << "wrote #{ d } change(s) (#{ _bytes } bytes) - #{ path }"
              end
            end

            fh.close

            redo
          end while nil

          @y << "(done with #{ count } file(s) total.)"
          ACHIEVED_
        else
          @y << "(had errors.)"
          UNABLE_
        end
      end

      class VCS_Session____  # this will definitely move to etc.

        class << self
          def via_path s
            pn = ::Pathname.new s
            pn.absolute? or raise ::ArgumentError
            begin
              if pn.join( DOT_GIT___ ).exist?
                found = pn
                break
              end
              pn_ = pn.dirname
              if pn_ == pn
                break
              end
              pn = pn_
              redo
            end while nil
            if found
              new pn
            else
              self._DO_ME
            end
          end

          private :new
        end  # >>

        DOT_GIT___ = '.git'

        def initialize pn
          @system_conduit = Home_::Library_::Open3
          @path = pn.to_path
        end

        def base_name_string
          GIT__
        end

        def VCS_stat path

          ::File::SEPARATOR == path[ 0 ] or raise ::ArgumentError

          if __is_tracked_right_now path
            __VCS_stat_right_now path
          end
        end

        def __is_tracked_right_now path

          _, o, e, t = @system_conduit.popen3(
            GIT__, 'ls-files', path, chdir: @path )

          t.value.exitstatus.zero? or fail
          s = e.gets
          s and raise s
          _s = o.gets
          _s ? ACHIEVED_ : UNABLE_
        end

        def __VCS_stat_right_now path

          _, o, e, t = @system_conduit.popen3(

            GIT__, 'status', '--porcelain', path )

          s = e.gets
          s and raise s
          t.value.exitstatus.zero? or fail
          s = o.gets
          if s
            MODI____ == s[ 0, 3 ] or self._DO_ME
            Stat__.new true
          else
            Stat__.new false
          end
        end

        GIT__ = 'git'
        MODI____ = ' M '  # hacked for now b.c meh
        Stat__ = ::Struct.new :is_modified

      end
    end
  end
end
