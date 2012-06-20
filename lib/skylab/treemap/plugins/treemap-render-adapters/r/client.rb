require 'skylab/interface/system'

module Skylab::Treemap::Plugins::TreemapRenderAdapters

  API = Skylab::Treemap::API

  module R
    extend Skylab::Autoloader
  end

  class R::Client
    extend Skylab::PubSub::Emitter
    emits :r_script, :success, :failure


    include Skylab::Interface::System::SelectLinesUntil

    def self.invoke(*a, &b)
      new(*a, &b).execute
    end
    def initialize csv_path, tempdir
      @bridge = nil
      @stop_after_script = false
      @csv_path = csv_path
      @tempdir = tempdir
      yield(self) if block_given?
      @title ||= 'Treemap'
    end

    attr_accessor :csv_path, :tempdir, :stop_after_script, :title

    def bridge
      @bridge ||= R::Bridge.new do |o|
        o.on_info  { |e| info e }
        o.on_error { |e| error e }
      end
    end

    def build_script_lines_enumerator
      @script or return false
      API::MemoryLinesEnumerator.new(@script)
    end

    DENY_RE = /[^- a-z0-9]+/i
    def e str
      str.to_s.gsub(DENY_RE, '')
    end

    def execute
      ready? or return
      generate_script! or return
      event_listeners[:r_script] and script.each { |s| emit(:r_script, s ) }
      stop_after_script and return true
      pipe_the_script or return
    end

    def failure msg, pathname=nil
      emit(:failure, message: msg, pathname: pathname) # nil pathname ok
      false
    end

    def success msg, pathname
      emit(:success, message: msg, pathname: pathname)
      true
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

    def pipe_the_script
      @script or return false # just to be sure
      bridge.ready? or return failed("count not find r: #{bridge.not_ready_reason}")
      mtime1 = pdf_path_guess.exist? && pdf_path_guess.stat.mtime
      lines = self.build_script_lines_enumerator
      Open3.popen3(bridge.executable_path, '--vanilla') do |sin, sout, serr|
        line = true
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
      report_result mtime1
    end

    def report_result mtime1
      mtime2 = pdf_path_guess.exist? && pdf_path_guess.stat.mtime
      msg, ok = if mtime1
        if mtime2
          if mtime1 == mtime2
            ["failed to create new file, old file intact (?)", false]
          else
            ["overwrote file", true] end
        else
          ["was there before and isnt't now!?", false] end
      elsif mtime2
        ["wrote new file", true]
      else
        ["failed to generate file or generated file not found", false]
      end
      send(ok ? :success : :failure, msg, pdf_path_guess)
    end

    def ready?
      tempdir.ready? or return
      csv_path.exist? or return failure("couldn't find csv: #{csv_path.pretty}")
      true
    end

    attr_reader :script
  end
end

