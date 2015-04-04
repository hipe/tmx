module Skylab::TestSupport

  module Quickie

    class Plugins::Wip_It

      def initialize svc
        @fuzzy_flag = svc.build_fuzzy_flag %w( -wip-them-all )
        @svc = svc
      end

      def opts_moniker
        @fuzzy_flag.some_opts_moniker
      end

      def args_moniker
      end

      def desc y
        y << "a search-replace hack: all `describe` blocks in"
        y << "the files that look \"normal\", add a `wip` tag"
        nil
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

        @BS = Autoloader_.require_sidesystem :BeautySalon

        @pwd = ::Dir.pwd
        @y = @svc.y

        ok = __resolve_first_path
        ok &&= __via_first_path_resolve_VCS_session
        ok && __via_VCS_session
      end

      def __resolve_first_path
        @st = @svc.to_test_path_stream
        @first_path = @st.gets
        @first_path && ACHIEVED_
      end

      def __via_first_path_resolve_VCS_session
        @sess = VCS_Session____.via_path ::File.expand_path @first_path, @pwd
        @sess && ACHIEVED_
      end

      def __via_VCS_session

        path = @first_path
        begin
          __process_path path
          path = @st.gets
          path or break
          redo
        end while nil
      end

      def __process_path path

        stat = @sess.VCS_stat ::File.expand_path path, @pwd
        if stat
          if stat.is_modified
            @y << "won't modify already modified file, skipping: #{ path }"
          else
            __work path
          end
        else
          @y << "not tracked by #{ @sess.base_name_string }, skipping: #{ path }"
        end
        nil
      end

      def __work path

        expag = TestSupport_.lib_.brazen::API.expression_agent_instance
        ok = true

        st = @BS.search_and_replace::API.call(
            :search, /^([ ]+)describe "((?:[^\\"]|\\.)+)" do$/m,
            :path, path,
            :replace, -> ws, inside do
              "#{ ws }describe \"#{ inside }\", wip: true do"
            end,
            :preview,
            :matches,
            :replace
        ) do | sym, & ev_p |

          ev_p[].express_into_under @y, expag
          if :error == sym
            ok = false
          end
        end

        begin
          match = st.gets
          match or break
          redo
        end while nil

        ok
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
          @system_conduit = TestSupport_::Library_::Open3
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
