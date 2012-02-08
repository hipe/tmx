require File.expand_path('../../../skylab', __FILE__)

module Skylab::Issue

  DATE_FORMAT = '%Y-%m-%d'
  ISSUES_FILE_NAME = 'doc/issues.md'
  ROOT = Pathname.new(File.expand_path('..', __FILE__)) # consider @autoload

  class Api
    def initialize &events
      @events = events
      @issues_manifest = {}
    end
    def invoke path, context
      path.reduce(Pathname.new('../api').expand_path(__FILE__)) do |m, s|
        require((m = m.join(s.to_s)).to_s)
        m
      end
      klass = path.reduce(self.class) do |m, s|
        m.const_get(s.to_s.gsub(/(?:^|-)([a-z])/) { $1.upcase })
      end
      _events = @events
      klass.new(self, context){ instance_eval(& _events) }.invoke
    end
    # getters for *persistent* models *objects* (think daemons):
    def issues_manifest pathname
      (pathname and ! pathname.empty?) or raise ArgumentError(
        "pathanme must be a non-empty string (had #{pathname.inspect})")
      @issues_manifest[pathname] ||= begin
        require "#{ROOT}/models/issues/manifest"
        Models::Issues::Manifest.new(pathname)
      end
    end
  end

  module Models
  end
end

