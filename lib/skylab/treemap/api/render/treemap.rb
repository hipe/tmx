require 'open3'

module Skylab::Treemap
  class API::Render::Treemap
    extend Skylab::PubSub::Emitter
    emits :info, :error, :r_script

    def self.invoke(*a, &b)
      new(*a, &b).execute
    end
    def initialize r, csv_path, tempdir
      @stop_after_script = false
      @r = r
      @csv_path = csv_path
      @tempdir = tempdir
      yield(self) if block_given?
      @title ||= 'Treemap'
    end

    attr_accessor :csv_path, :r, :tempdir, :stop_after_script, :title

    def build_script_lines_enumerator
      @script or return false
      MemoryLinesEnumerator.new(@script)
    end

    DENY_RE = /[^- a-z0-9]+/i
    def e str
      str.to_s.gsub(DENY_RE, '')
    end

    def error msg
      emit(:error, "unable to generate trreemap: #{msg}")
      false
    end

    def execute
      ready? or return
      generate_script! or return
      event_listeners[:r_script] and script.each { |s| emit(:r_script, s ) }
      stop_after_script and return true
      pipe_the_script
    end

    def generate_script!
      (@script ||= []).clear
      @script << '# install.packages("portfolio") # this installs it, only necessary once'
      @script << 'library(portfolio)'
      @script << %|data <- read.csv("#{csv_path}")|
      @script << %|map.market(id=data$id, area=data$area, group=data$group, color=data$color, main="#{e title}")|
      @script << "# end of generated script"
      @script
    end

    def self.pdf_path_guess
      @pdf_path_guess ||= API::Path.new(File.join(FileUtils.pwd, 'Rplots.pdf'))
    end
    def pdf_path_guess
      self.class.pdf_path_guess
    end

    NUM_BYTES = 4096
    def pipe_the_script
      @script or return false # just to be sure
      r.ready? or return error("r was not available: #{r.not_ready_reason}")
      verb = pdf_path_guess.exist? ? 'overwrite' : 'write'
      lines = self.build_script_lines_enumerator
      line = true
      Open3.popen3(r.executable_path, '--vanilla') do |sin, sout, serr|
        loop do
          bytes = select_lines_until(0.3, sout: sout, serr: serr) do |o|
            o.on_sout { |e| $stderr.write "OUT-->#{e}" }
            o.on_serr { |e| $stderr.write "ERR->#{e}" }
          end
          if line and line = lines.gets
            $stderr.puts "MINE-->#{line}"
            sin.puts line
          end
          if 0 == bytes and ! line
            break
          end
        end
      end # popen3
    end

    def ready?
      tempdir.ready? or return
      csv_path.exist? or return error("csv not found: #{csv_path.pretty}")
      true
    end

    attr_reader :script


    def select_lines_until(timeout_seconds, streams)
      name = Hash[ * streams.map { |k, v| [v.object_id, k] }.flatten(1) ]
      remaining = streams.values
      e = StringEmitterFactory.new(*name.values).new
      yield(e)
      bytes = 0
      while remaining.any?
        read, _w, _e = IO.select(remaining, nil, nil, timeout_seconds)
        read or break
        read.each do |io|
          str = done = nil
          begin
            str = io.readpartial NUM_BYTES
            done = io.closed?
          rescue EOFError => e
            done = true
          end
          if str
            bytes += str.length
            e.emit(name[io.object_id], str)
          end
          if done
            remaining[remaining.index(io)] = nil
            remaining.compact!
          end
        end
      end
      e.flush!
      bytes
    end
  end
  module StringEmitterFactory
    def self.new(*a)
      Class.new(StringEmitter).class_eval do
        extend Skylab::PubSub::Emitter
        emits(*a)
        alias_method :emit_string, :emit
        alias_method :emit, :progressive_emit
        self
      end
    end
  end
  class StringEmitter
    def initialize
      @b = Hash.new { |h, k| h[k] = StringIO.new }
      @s = nil
    end
    def flush!
      @b.each do |k, b|
        _scan_out k, b, true
      end
    end
    def progressive_emit k, string
      (buffer = @b[k]).write string
      if buffer.string.index("\n")
        _scan_out k, buffer
      end
    end
    def _scan_out k, buffer, rest=false
      if @s
        @s.string = buffer.string
      else
        @s = StringScanner.new(buffer.string)
      end
      while line = @s.scan_until(/\n/)
        emit_string(k, line)
      end
      if rest
        unless @s.eos?
          emit_string(k, @s.rest)
        end
      end
      buffer.truncate(0)
      buffer.write(@s.rest)
    end
  end
  class MemoryLinesEnumerator < ::Enumerator
    def initialize arr
      block_given? and fail('no')
      index = -1
      @last_number = ->() { index + 1 }
      @next = ->() do
        if (index + 1) < arr.length
          arr[index += 1]
        else
          nil
        end
      end
      super() do |y|
        while index + 1 < arr.length
          y << arr[index += 1]
        end
      end
    end
    def last_number
      @last_number.call
    end
    alias_method :orig_next, :next
    def gets
      @next.call
    end
  end
end

