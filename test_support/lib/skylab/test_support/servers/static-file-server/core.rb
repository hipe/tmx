module Skylab::TestSupport

  class Servers::Static_File_Server  # [#041] ..

    # modeled like an actor but wraps something that is long-running.

    def initialize doc_root_s, * x_a, & oes_p

      @doc_root = doc_root_s
      @_oes_p = oes_p

      @filesystem = nil
      @PID_path = nil
      @processes = nil

      if x_a.length.nonzero?
        st = Common_::Scanner.via_array x_a
        begin
          _m = :"#{ st.gets_one }="
          send _m, st.gets_one
        end while st.unparsed_exists
      end

      if ! @filesystem
        @filesystem = Home_.lib_.system.filesystem
      end

      # ~

      if ! @PID_path
        @PID_path = @filesystem.tmpdir_path
      end

      @port ||= 1324

      @processes ||= Home_.lib_.system.processes
    end

    attr_writer(
      :filesystem,
      :PID_path,
      :port,
    )

    def execute

      _ok = ___resolve_PID_classifications
      _ok && __via_PID_classifications
    end

    def ___resolve_PID_classifications

      x = Here_::Classify_PID_file___[ @PID_path, @filesystem, & @_oes_p ]
      if x
        @_PID_file = x
        ACHIEVED_
      else
        x
      end
    end

    def __via_PID_classifications

      # the below code is based on "[#]/figure-1" a logic flowchart.

      if @_PID_file.did_exist
        __when_PID_file_existed
      else
        _maybe_start_server
      end
    end

    def __when_PID_file_existed

      kn = @processes.record_for(
        @_PID_file.PID, :etime, :pid, :state, & @_oes_p )

      if kn
        if kn.is_known_known
          _rec = kn.value_x
          ___express_that_process_is_still_running _rec
        else
          _ok = __cleanup_PID_file
          _ok && _maybe_start_server
        end
      else
        kn
      end
    end

    def ___express_that_process_is_still_running rec

      @_oes_p.call :info, :expression, :already_running do | y |

        unit, x = Home_.lib_.basic::Time::EN::Summarize[ rec.etime.to_i ]

        _f_s = ( '%0.2f' % x )

        y << "server is already running: #{
          }PID #{ rec.pid } (status: #{ rec.state }) #{
           }up for #{ _f_s } #{ plural_noun unit.id2name }"
      end

      ACHIEVED_
    end

    def __cleanup_PID_file

      path = @_PID_file.path

      @_oes_p.call :info, :expression, :removing_stale_PID do | y |
        y << "removing stale PID file - #{ pth path }"
      end

      _num_d = @filesystem.unlink path
      1 == _num_d or self._SANITY
      ACHIEVED_
    end

    def _maybe_start_server

      _ok = ___doc_root_must_exist
      _ok && __start_server
    end

    def ___doc_root_must_exist

      Home_.lib_.system_lib::Filesystem::Normalizations::Upstream_IO.via(
        :path, @doc_root,
        :must_be_ftype, :DIRECTORY_FTYPE,
        :filesystem, @filesystem,
        & @_oes_p )
    end

    def __process_is_still_running
      @processes.has_PID @_PID_file.PID
    end

    def __start_server

      o = Here_::Rainbow_Kick___.new( & @_oes_p )
      o.doc_root = @doc_root
      o.filesystem = @filesystem
      o.PID_path = @_PID_file.path
      o.port = @port
      o.execute
    end

    DEFAULT_BASENAME_ = 'static-file-server.pid'
    Here_ = self
  end
end
