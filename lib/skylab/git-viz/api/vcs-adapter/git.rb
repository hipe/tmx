require 'grit'

module Skylab::GitViz::Api::VcsAdapter
  class Git < Struct.new(:runtime)
    def repo path
      require File.expand_path('../git/repo', __FILE__)
      self.class::Repo.get(path, runtime)
    end
  end
end

