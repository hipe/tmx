require 'adsf'
require 'rack'

module Skylab::Dependency

  class StaticFileServer

    extend PubSub::Emitter

    event_class PubSub::Event::Textual

    include Dependency::Services::FileUtils

    emits info: :all, warn: :all, error: :all # used internally

  public

    def doc_root_pathname
      @doc_root_pathname ||= begin
        if doc_root
          ::Pathname.new doc_root.to_s
        end
      end
    end

    def run
      start_unless_running
    end

  private

    default_log_level = :info
    default_port = 1324
    levels = PubSub::Emitter::COMMON_LEVELS
    options = ::Struct.new :doc_root, :log_level, :pid_path, :port

    define_method :initialize do |*args|
      block_given? and raise ::ArgumentError.new 'no block cleverness yet'
      @downstream = $stderr       # can be made configurable if necessary
      ::Hash === args.last and opts_h = args.pop # first, before below args
      args_h = { }
      args.empty? or args_h[:doc_root] = args.shift
      args.empty? or args_h[:pid_path] = args.shift
      args.empty? or raise ::ArgumentError.new 'too many args'
      if opts_h
        (a = opts_h.keys & args_h.keys).empty? or
          raise ::ArgumentError.new "duplicated in args, opts: #{ a.join ', ' }"
        args_h.merge! opts_h
        opts_h = nil
      end
      args_h =
        { log_level: default_log_level, port: default_port }.merge args_h
      opts = options.new
      args_h.each { |k, v| opts[k] = v } # effectively validates keys
      on_all do |e|
        if levels.index(e.stream_name) >= log_level_i # gigo
          downstream.puts "FILE_SERVER (#{ e.stream_name }): #{ e.text }"
        end
      end
      opts.members.each { |k| send "#{k}=", opts[k] }
    end

    attr_reader :doc_root

    def doc_root= root
      @doc_root_pathname = nil
      @doc_root = root
    end

    attr_reader :downstream

    def error msg
      emit :error, msg
      nil
    end

    def filesystem_ok &er
      result = false
      error = -> msg { ( er || -> m { error m } )[ msg ] }
      begin
        if ! pid_pathname.dirname.writable?
          error[ "not writable: #{ pid_pathname.dirname }" ]
          break
        end
        if ! doc_root_pathname
          error[ "doc_root not set" ]
          break
        end
        if ! doc_root_pathname.exist?
          error[ "doc_root directory not found - #{ doc_root_pathname }" ]
          break
        end
        if ! doc_root_pathname.directory?
          error[ "not a directory - #{ doc_root_pathname }" ]
          break
        end
        result = true
      end while nil
      result
    end

    def fu_output_message msg # compat with fileutils
      info msg
    end

    def info msg
      emit :info, msg
      nil
    end

    attr_reader :log_level, :log_level_i

    define_method :log_level= do |level|
      idx = levels.index level
      idx or raise ::ArgumentError.new "invalid log level: #{level.inspect} -#{
       } expecting one of : (#{ levels.map(&:inspect).join ' ' })"
      @log_level = level
      @log_level_i = idx
      level
    end

    attr_reader :pid_path

    def pid_path= x
      @pid_pathname = nil
      @pid_path = x
    end

    dirname_basename = -> pid_path do
      pn = ::Pathname.new pid_path.to_s
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

    default_basename = 'static-file-server.pid'

    define_method :pid_pathname do |&er|
      @pid_pathname ||= begin
        pathname = nil
        error = -> msg  { (er || -> m { self.error m } )[ msg ] }
        begin
          if ! pid_path
            error[ "pid_path was not set" ]
            break
          end
          dirname, basename = dirname_basename[ pid_path ]
          if ! dirname.exist?
            error[ "pid dir not found: #{ dirname }" ]
            break
          end
          if ! dirname.directory?
            error[ "not a directory: #{ dirname }" ]
            break
          end
          pathname = dirname.join( basename || default_basename )
        end while nil
        pathname
      end
    end

    attr_accessor :port

    def rack_app
      @rack_app ||= begin
        rack_app = nil
        begin
          info "building rack app (doc_root: #{ doc_root } port: #{ port })"
          doc_root = doc_root_pathname.to_s # b/c of dsl scope too!
          rack_builder = Headless::FUN.quietly do
            ::Rack::Builder.new do
              use ::Rack::CommonLogger
              use ::Rack::ShowExceptions
              use ::Rack::Lint
              use ::Adsf::Rack::IndexFileFinder, root: doc_root
              run ::Rack::File.new( doc_root )
            end
          end
          rack_app = rack_builder.to_app
        end while nil
        rack_app
      end
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

    def running?
      result = false
      begin
        pid_pathname.exist? or break
        pid_str = pid_pathname.read.strip
        if /\A\d+\z/ !~ pid_str
          warn "pid file content is not a digit: #{ pid_str.inspect }"
          break
        end
        lines = `ps -p #{ pid_str } -o%cpu -ostat`.strip.split "\n" # [#sl-120]
        header = lines.shift
        if '%CPU STAT' != header
          warn "failed to parse first line of ps response: #{ header.inspect }"
          break
        end
        if 0 == lines.length
          info "removing stale pid file - #{ pid_pathname.basename }"
          rm pid_pathname.to_s, verbose: true
          break
        end
        if 1 < lines.length
          warn "why are there multiple lines?"
        end
        result = pid_str.to_i
      end while nil
      result
    end

    def start
      result = false
      running? and fail "won't start server when it's already running."
      begin
        filesystem_ok { |e| error "can't start server - #{e}" } or break
        rack_app or break
        rack_handler or break
        p = fork do
          pid = ::Process.pid
          info "writing new pid file - #{ pid_pathname.basename } (pid: #{pid})"
          pid_pathname.open( 'w' ) { |o| o.write pid }
          rack_handler.run rack_app, :Port => port # Errno::EADDRINUSE
          $stderr.puts "YOU SHOULD NEVER SEE THIS: ROCK HANOI"
        end
        ::Process.detach p
        info "parent process has parent process id : #{ ::Process.pid }#{
          } and child id: #{ p }"
        result = p
      end while nil
      result
    end

    def start_unless_running
      pid = nil
      begin
        pid_pathname { |m| error "can't start server - #{ m }" } or break
          # used by running? and start so do it here
        p = running?
        if p
          info "running (pid ##{ p } in #{ pid_pathname.basename })."
          break
        end
        pid = start
      end while nil
      pid
    end

    def warn msg
      emit :warn, msg
      false
    end
  end
end
