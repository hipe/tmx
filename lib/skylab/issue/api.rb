require_relative '../../skylab'

module Skylab::Issue

  DATE_FORMAT = '%Y-%m-%d'
  ISSUES_FILE_NAME = 'doc/issues.md'
  ROOT = Pathname.new(File.expand_path('..', __FILE__)) # consider @autoload

  class Api
    extend Skylab::Autoloader

    # creates a new instance of the action
    def action *path
      path.reduce(Pathname.new('../api').expand_path(__FILE__)) do |m, s|
        require((m = m.join(s.to_s)).to_s)
        m
      end
      klass = path.reduce(self.class) do |m, s|
        m.const_get(s.to_s.gsub(/(?:^|-)([a-z])/) { $1.upcase })
      end
      klass.new(self) # hide how you construct yourself
    end
    # getters for *persistent* models *objects* (think daemons):
    def issues_manifest pathname
      @issues_manifest ||= {}
      (pathname and ! pathname.empty?) or raise ArgumentError(
        "pathanme must be a non-empty string (had #{pathname.inspect})")
      @issues_manifest[pathname] ||= begin
        require "#{ROOT}/models/issues/manifest"
        Models::Issues::Manifest.new(pathname)
      end
    end
  end

  module Models
    extend Skylab::Autoloader
  end
end

