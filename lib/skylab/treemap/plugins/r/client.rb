require 'skylab/interface/system'
require 'skylab/meta-hell/autoloader/autovivifying'

module Skylab::Treemap::Plugins

  API = Skylab::Treemap::API

  module R
    extend Skylab::Autoloader
    module CLI
      module Actions
        extend Skylab::MetaHell::Autoloader::Autovivifying
        extend Skylab::Porcelain::Bleeding::Stubs
      end
    end
  end

  class R::Client
    extend Skylab::PubSub::Emitter
    emits :r_script, :success, :failure

    def load_attributes o
      o.attribute :r_script_stream, :enum => [:payload], stops_after: :r_script, stop_implied: true
    end

    def load_options cli
      cli.option_syntax.define! do |o|
        s = cli.stylus
        separator('')
        separator(s.hdr 'r-specific options:')
        on('--r-script', 'output to stdout the generated r script, stop.') { o[:r_script_stream] = :payload }
      end
    end


    include Skylab::Interface::System::SelectLinesUntil

    def initialize
      block_given? and raise ArgumentError.new("for now, events are not wired here")
      @bridge = nil
      @stop_after_script = false
      @csv_path = nil
      @tempdir = nil
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

    def invoke &block
      block.call self # will need to re-wire if we ever re-run the same client
      execute
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
          bytes = select_lines_until(0.3, sout: sout, serr: serr) do |o| # #todo #hl-102
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

    def update_parameters! csv_path, tempdir
      @csv_path = csv_path
      @tempdir = tempdir
      self
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

