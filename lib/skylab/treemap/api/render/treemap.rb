require 'shellwords'

module Skylab::Treemap
  class API::Render::Treemap
    extend Skylab::PubSub::Emitter
    emits :info, :error, :r_script

    def self.invoke(*a, &b)
      new(*a, &b).execute
    end
    def initialize r, csv_path, tempdir
      yield(self) if block_given?
      @csv_path = csv_path
      @r = r
      @tempdir = tempdir
      @stop_after_script = false
      @title = title || 'Treemap'
    end

    attr_accessor :csv_path, :r, :tempdir, :stop_after_script, :title

    DENY_RE = /[^- a-z0-9]+/i
    def e str
      str.to_s.gsub(DENY_RE, '')
    end

    def error msg
      emit(:error, msg)
      false
    end

    def execute
      ready? or return
      generate_script! or return
      event_listeners[:r_script] and script.each { |s| emit(:r_script, s ) }
      stop_after_script and return true
      false
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

    def ready?
      tempdir.ready? or return
      csv_path.exist? or return error("csv not found: #{csv_path.pretty}")
      true
    end

    attr_reader :script

  end
end

