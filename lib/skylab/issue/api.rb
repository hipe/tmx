require_relative '../../skylab'
require 'skylab/meta-hell/autoloader/autovivifying'

module Skylab::Issue

  DATE_FORMAT = '%Y-%m-%d'
  ISSUES_FILE_NAME = 'doc/issues.md'
  ROOT = Pathname.new(File.expand_path('..', __FILE__)) # consider @autoload

  class Api
    extend Skylab::MetaHell::Autoloader::Autovivifying
    include Skylab::Autoloader::Inflection::Methods

    # creates a new instance of the action
    def action *path
      path.reduce(self.class) { |m, s| m.const_get(constantize(s)) }.new(self)
        # hide how you construct yourself
    end
    # getters for *persistent* models *objects* (think daemons):
    def issues_manifest pathname
      @issues_manifest ||= {}
      (pathname and ! pathname.empty?) or raise ArgumentError(
        "pathanme must be a non-empty string (had #{pathname.inspect})")
      @issues_manifest[pathname] ||= begin
        Models::Issues::Manifest.new(pathname)
      end
    end
  end

  module Models
    extend Skylab::Autoloader
  end
end

