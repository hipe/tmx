require 'rack'
require 'adsf'
require 'fileutils'
require File.expand_path('../constants', __FILE__)

module Skylab::Dependency::TestSupport::StaticFileServer
  class << self
    def start_unless_running ui=nil
      ui ||= Struct.new(:out, :err).new($stdout, $stderr)
      Server.new(ui).start_unless_running({})
    end
  end
  class Server # private
    include ::Skylab::Dependency::TestSupport::Constants
    def initialize ui
      @ui = ui
      @port = 1324
      @root = nil
    end
    attr_reader :pid
    attr_reader :ui
    def start_unless_running req
      parse_request(req) or return false
      if running?
        @ui.err.puts "#{self.class} is (already) running. (pid ##{pid})."
        return true
      end
      start
    end
    def start
      running? and fail("won't start server when it's already running.")
      handler = determine_handler or return false
      app or return false
      pid = fork { _run handler, app }
      Process.detach(pid)
      @ui.err.puts "parent process has parent process id : #{Process.pid} and child id: #{pid}"
    end
    def _run handler, app
      pid = Process.pid
      File.open(pid_file, 'w') { |fh| fh.write(pid) }
      puts "Wrote pid. pid is: #{Process.pid}, using #{handler}"
      Signal.trap("SIGINT") do
        @ui.err.puts "received SIGINT signal. Sorry, there is no exit (rack bug?)."
      end
      handler.run(app, :Port => @port)
    end
    def parse_request req
      req = req.dup
      @port = req.delete(:port) || @port
      @root = req.delete(:root) || @root || FIXTURES_DIR
      @handler = req.delete(:handler) || @handler
      true
    end
    def app
      @app ||= begin
        _root = @root
        @ui.err.puts "using app root: #{_root}"
        Rack::Builder.new do
          use Rack::CommonLogger
          use Rack::ShowExceptions
          use Rack::Lint
          use Adsf::Rack::IndexFileFinder, :root => _root
          run Rack::File.new(_root)
        end.to_app
      end
    end
    def running?
      @pid = nil
      File.exist?(pid_file) or return false
      pid = File.read(pid_file).strip
      /\A\d+\z/ =~ pid or _warn("pid file content is not a digit: #{pid.inspect}")
      lines = `ps -p #{pid} -o%cpu -ostat`.strip.split("\n")
      (l = lines.shift) == '%CPU STAT' or return _warn("failed to parse ps response: #{l}")
      case lines.size
      when 0 ; return remove_stale_pid_file
      when 1 ; @pid = pid ; true
      else   ; @pid = pid ; _warn("why are there multiple lines?") ; true
      end
    end
  protected
    def  _warn msg
      @ui.err.puts "WARNING #{msg}"
      false
    end
    def determine_handler
      if h = @handler
        unless handler = Rack::Handler.get(h)
          @ui.err.puts("no: #{h}")
          return false
        end
      else
        begin
          handler = Rack::Handler::Mongrel
        rescue LoadError
          handler = Rack::Handler::WEBrick
        end
      end
      handler
    end
    def pid_file
      @pid_file ||= File.join(TMP_DIR, 'test-server.pid')
    end
    def remove_stale_pid_file
      @ui.err.puts "removing stale pid file.."
      FileUtils.rm(pid_file, :verbose => true)
      false
    end
  end
end

if $PROGRAM_NAME == __FILE__
  Skylab::Dependency::TestSupport::StaticFileServer.start_unless_running
end
