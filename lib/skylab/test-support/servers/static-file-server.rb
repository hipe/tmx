module Skylab::TestSupport

  class Servers::Static_File_Server

    PubSub = Subsys::Services::PubSub

    extend PubSub::Emitter

    event_class PubSub::Event::Textual

    emits info: :all, warn: :all, error: :all  # used internally

    include Subsys::Services::FileUtils

    def initialize *a, &b  # [ doc_root_str ] [ opt_hash ] <<no blocks>>
      Subsys::Services.kick :Adsf, :Rack
      init_event_handling
      Parse_args_[ h = { }, a, b ]
      h = { log_level_i: DEFAULT_LOG_LEVEL_, port: DEFAULT_PORT_ }.merge h
      @doc_root = @doc_root_pathname = @rack_app = nil
      h.each { |k, v| send OPT_H_.fetch( k ), v }
      @downstream = Stderr_[]  # can be made configurable if necessary
      nil
    end

    DEFAULT_LOG_LEVEL_ = :info

    DEFAULT_PORT_ = 1324

    OPT_H_ = {
      doc_root: :set_doc_root,
      port: :set_port,
      pid_path: :set_pid_path,
      log_level_i: :set_log_level_i
    }.freeze

    def run
      start_unless_running
    end

  private

    def init_event_handling
      on_all do |e|
        lvl_d = LEVELS_.index e.stream_name
        if ! lvl_d || lvl_d >= @log_level_idx
          @downstream.puts render_event_as_line( e )
        end
      end
      nil
    end

    LEVELS_= PubSub::Emitter::COMMON_LEVELS

    def render_event_as_line e
      ">>> (#{ moniker } #{ e.stream_name } - #{ e.text })"
    end

    def error msg
      emit :error, msg
      false
    end

    def warn msg
      emit :warn, msg
      false
    end

    def info msg
      emit :info, msg
      nil
    end

    def fu_output_message msg # compat with fileutils
      info msg
    end

    def moniker
      MONIKER_
    end
    MONIKER_ = 'static file server'

    Parse_args_ = -> arg_h, a, b do
      b and raise ::ArgumentError, "unexpected block"
      ::Hash === a.last and opt_h = a.pop
      a.length.nonzero? and arg_h[ :doc_root ] = a.shift
      a.length.nonzero? and raise ::ArgumentError, "too many args"
      opt_h and Merge_safely_[ arg_h, opt_h ]
      nil
    end

    Merge_safely_ = -> arg_h, opt_h do
      ( a = opt_h.keys & arg_h.keys ).empty? or raise ::ArgumentError.
        new "duplicated in args, opts: #{ a.join ', ' }"
      arg_h.merge! opt_h
      nil
    end

    def set_doc_root root
      @doc_root_pathname = nil
      @doc_root = root
    end

    def set_port port
      @port = port
    end

    def set_pid_path x
      @pid_path_arg = x
      @pid_pathname = nil
      nil
    end

    def set_log_level_i level_i
      level_a = LEVELS_
      (( idx = level_a.index level_i )) or raise ::ArgumentError, "invalid #{
        }log level: #{ level_i.inspect } - expecting one of : #{
        } (#{ level_a.map( & :inspect ) *' ' })"
      @log_level_i = level_i
      @log_level_idx = idx
      nil
    end

    def start_unless_running
      -> do  # #result-block
        fetch_pid_pathname { |m| error "can't start server - #{ m }" } or
          break false
        (( p = any_pid_of_known_already_running_process )) and break info(
          "using already running server process - (pid #{ p } in #{
            }#{ @pid_pathname.basename })." )
        start  # result is pid
      end.call
    end

    def pid_pathname
      fetch_pid_pathname
    end

    def fetch_pid_pathname &els
      if @pid_pathname then @pid_pathname
      elsif false == @pid_pathname
        els ? els[ "pid pathname is in failure state" ] : false
      else
        init_pid_pathname els
      end
    end

    def init_pid_pathname er
      pn = nil ; bork = -> msg { ( er || method( :error ) )[ msg ] }
      r = -> do  # #result-block
        @pid_path_arg or break bork[ "pid_path arg was not set" ]
        dirname, basename = Dirname_basename_[ @pid_path_arg ]
        dirname.exist? or break bork[ "pid dir not found: #{ dirname }" ]
        dirname.directory? or break bork[ "not a directory: #{ dirname }" ]
        pn = r = dirname.join( basename || DEFAULT_BASENAME_ )
      end.call
      @pid_pathname = pn || false
      r
    end

    DEFAULT_BASENAME_ = 'static-file-server.pid'.freeze

    Dirname_basename_ = -> pid_path_arg do
      pn = ::Pathname.new pid_path_arg.to_s
      if pn.exist?                # if the file exists
        if pn.directory?          #   and it looks like a directory
          dirname = pn            #     then assume that that's the pid dir
        else                      #   otherwise
          dirname = pn.dirname    #     split it into a dirname
          basename = pn.basename  #     and a basename
        end                       #
      elsif '' == pn.extname      # otherwise, if the path has no extension,
        dirname = pn              #   assume it's supposed to be a dir
      else                        # otherwise assume it's supposed to be a file
        dirname = pn.dirname      #   split it into a dirname
        basename = pn.basename    #   and a basename
      end
      [dirname, basename]
    end

    def any_pid_of_known_already_running_process  # #hacks
      begin
        pid_pathname && @pid_pathname.exist? or break
        pid_s = @pid_pathname.read.strip
        /\A\d+\z/ =~ pid_s or break warn( "pid file content is not a #{
          }digit: #{ pid_s.inspect }" )
        cmd = "ps -p #{ pid_s } -o%cpu -ostat"
        hack_a = `#{ cmd }`.strip.split "\n"  # [#sl-120]
        header = hack_a.shift
        '%CPU STAT' == header or break warn( "failed to parse first line #{
          }of ps response - #{ header.inspect }" )
        hack_a.length.zero? and break remove_stale_pid_file
        1 < hack_a.length and warn "multiple lines in pid file?"
        r = pid_s.to_i
      end while nil
      r
    end

    def remove_stale_pid_file
      info "removing stale pid file - #{ @pid_pathname.basename }"
      rm @pid_pathname.to_s, verbose: true
      nil
    end

    def start
      begin
        fetch_ok_filesystem_status do |e|
          error "can't start server - #{ e }"
        end or break
        rack_app or break
        rack_handler or break
        @port && @pid_pathname && @rack_handler && @rack_app or fail "sanity"
        p = fork do
          pid = ::Process.pid
          info "writing new pid file - #{ @pid_pathname.basename } #{
            } (pid: #{ pid })"
          @pid_pathname.open( 'w' ) { |o| o.write pid }
          set_interrupt_handler
          @rack_handler.run @rack_app, :Port => @port  # Errno::EADDRINUSE
          @downstream.puts "YOU SHOULD NEVER SEE THIS: ROCK HANOI"
          nil
        end
        p or break
        ::Process.detach p
        info "parent process has parent process id : #{ ::Process.pid }#{
          } and child id: #{ p }"
        r = p
      end while nil
      r
    end

    def set_interrupt_handler
      trap :INT do
        @downstream.puts "#{ moniker } received interrupt signal. goodbye."
        exit! 0
      end
    end

    def fetch_ok_filesystem_status &er
      begin
        bork = -> msg { ( er || method( :error ) )[ msg ] }
        pid_pathname or break bork[ "failed to resolve pid pathname." ]
        @pid_pathname.dirname.writable? or break bork[ "not writable: #{
          }#{ @pid_pathname.dirname }" ]
        doc_root_pathname or break bork[ "doc_root not set" ]
        @doc_root_pathname.exist? or break bork[ "doc_root directory not #{
          }found - #{ doc_root_pathname }" ]
        @doc_root_pathname.directory? or break bork[ "not a directory - #{
          }#{ @doc_root_pathname }" ]
        r = true
      end while nil
      r
    end

    def doc_root_pathname
      if @doc_root_pathname.nil?
        @doc_root_pathname = @doc_root ? ::Pathname.new( @doc_root ) : false
      end
      @doc_root_pathname
    end
    public :doc_root_pathname

    def rack_app
      @rack_app.nil? and @rack_app = build_rack_app
      @rack_app
    end

    def build_rack_app
      info "building rack app (doc_root: #{ @doc_root } port: #{ @port })"
      doc_root_ = @doc_root
      builder = ::Rack::Builder.new do
        use ::Rack::CommonLogger
        use ::Rack::ShowExceptions
        use ::Rack::Lint
        use ::Adsf::Rack::IndexFileFinder, root: doc_root_
        run ::Rack::File.new( doc_root_ )
      end
      builder.to_app || false
    end

    def rack_handler
      @rack_handler ||= resolve_rack_handler
    end

    def resolve_rack_handler
      # ::Rack::Handler.get
      begin
        ::Rack::Handler::Mongrel
      rescue ::LoadError
        ::Rack::Handler::WEBrick
      end
    end
  end
end
