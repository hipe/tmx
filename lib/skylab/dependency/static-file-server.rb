require 'rack'
require 'adsf'
require 'fileutils'
require File.expand_path('../../../skylab', __FILE__)
require 'skylab/slake/muxer'

module Skylab ; end

module Skylab::Dependency
  class StaticFileServer
    DEFAULT_PORT = 1324
    include FileUtils
    extend ::Skylab::Slake::Muxer
    emits :all, :info => :all
    def determine_rack_handler
      if h = @rack_handler
        handler = Rack::Handler.get(h) or fail(
          "Failed to get rack handler from #{h.inspect}")
      else
        begin
          handler = Rack::Handler::Mongrel
        rescue LoadError
          handler = Rack::Handler::WEBrick
        end
      end
      handler
    end
    attr_accessor :document_root
    alias_method :_emit, :emit
    def emit type, message
      _emit type, "#{message_prefix}#{message}"
    end
    def fu_output_message msg # see fileutils.rb
      emit :info, msg
    end
    def initialize opts=nil
      block_given? and yield(self)
      event_listeners[:all] ||= lambda { |e| $stderr.puts e }
      case opts
      when String, Pathname ; opts = { :document_root => opts }
      end
      opts and opts.each { |k, v| send("#{k}=", v) }
      @port ||= DEFAULT_PORT
    end
    def message_prefix
      @message_prefix ||= "#{name} "
    end
    def name
      @name || self.class.to_s
    end
    attr_reader :pid
    def pid_file
      @pid_file ||= begin
        File.directory?(pid_file_dirname) or
          fail("Can't use #{self.class} without an existing pid_file_dirname: #{pid_file_basename}")
        File.join(pid_file_dirname, pid_file_basename)
      end
    end
    attr_writer :pid_file
    def pid_file_basename
      @pid_file_basename ||= "#{self.class.to_s.gsub('::', '-').downcase}-#{self.class.next_unique_id}.pid"
    end
    attr_writer :pid_file_basename
    def pid_file_dirname
      @pid_file_diranme || './tmp'
    end
    attr_writer :pid_file_dirname
    attr_accessor :port
    def rack_app
      @rack_app ||= begin
        docroot = self.document_root or fail("No document_root set, can't create app")
        emit :info, "building rack app with document_root: #{docroot}"
        Rack::Builder.new do
          use Rack::CommonLogger
          use Rack::ShowExceptions
          use Rack::Lint
          use Adsf::Rack::IndexFileFinder, :root => docroot
          run Rack::File.new(docroot)
        end.to_app
      end
    end
    attr_writer :rack_handler
    def _run_rack_app handler, app
      pid = Process.pid
      File.open(pid_file, 'w') { |fh| fh.write(pid) }
      emit(:info, "Wrote pid (##{pid}) to file (#{File.basename(pid_file)}) using #{handler}")
      Signal.trap("SIGINT") do
        emit(:info, "received SIGINT signal. Sorry, there is no exit (adsf issue?).  Try KILL !?")
      end
      handler.run(app, :Port => port)
    end
    def running?
      @pid = nil
      File.exist?(pid_file) or return false
      pid = File.read(pid_file).strip
      /\A\d+\z/ =~ pid or return warn("pid file content is not a digit: #{pid.inspect}")
      lines = `ps -p #{pid} -o%cpu -ostat`.strip.split("\n")
      '%CPU STAT' == (l = lines.shift) or return warn("failed to parse ps response: #{l}")
      case lines.size
      when 0 ; remove_stale_pid_file ; false
      when 1 ; @pid = pid ; true
      else   ; @pid = pid ; warn("why are there multiple lines?") ; true
    end
    end
    def remove_stale_pid_file
      emit :info, "removing stale pid file.."
      rm pid_file, :verbose => true
    end
    def start
      running? and fail("won't start server when it's already running.")
      handler = determine_rack_handler or return false
      rack_app = self.rack_app or return false
      pid = fork { _run_rack_app handler, rack_app }
      Process.detach(pid)
      emit(:info, "parent process has parent process id : #{Process.pid} " <<
        "and child id: #{pid}")
      pid
    end
   def start_unless_running
      if running?
        emit :info, "is (already) running (pid ##{pid} in file #{File.basename(pid_file)})."
        return true
      end
      start
    end
    def warn msg
      emit :warning, msg
      false
    end
  end
  class << StaticFileServer
    id = 0
    define_method(:next_unique_id) { id += 1 }
  end
end

