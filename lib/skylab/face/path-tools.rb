require 'fileutils'
require 'shellwords'

module Skylab; end

module Skylab::Face
  module PathTools
    extend self
    def beautify_path path
      path.sub(/\A#{
        Regexp.escape(FileUtils.pwd.sub(/\A\/private\//, '/'))
      }/, '.')
    end
    def home
      if ! instance_variable_defined?('@home') or @home.nil?
        @home = ENV['HOME']
      end
      @home
    end
    def home_re
      @home_re ||= %r{\A#{Regexp.escape home}(?=/|\z)}
    end
    def pretty_path path
      home = self.home ; pwd = self.pwd
      both = [home, pwd]
      if home and pwd and
        idx = [->{home.index(pwd)}, ->{pwd.index(home)}].index { |p| 0 == p.call } and
        0 == path.index([home, pwd][idx])
      then
        if 0 == idx then pwd = false else home = false end
      end
      path = path.sub(home_re, '~') if home
      path = path.sub(pwd_re,  '.') if pwd
      path
    end
    def pwd
      FileUtils.pwd
    end
    def pwd_re
      %r{\A#{Regexp.escape pwd}(?=/|\z)}
    end
    def escape_path path
      (path.to_s =~ / |\$|'/) ? ::Shellwords.shellescape(path) : path.to_s
    end
  end
end
