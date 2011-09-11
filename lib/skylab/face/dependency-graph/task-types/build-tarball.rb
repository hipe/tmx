require File.expand_path('../../task', __FILE__)
require 'pathname'

module Skylab::Face
  class DependencyGraph
    class TaskTypes::BuildTarball < self
      attribute :derpa
      def initialize_child_graph data
        data.key?('build tarball') or return failed("missing required key: 'build tarball' in data")
        pathname = Pathname.new(data['build tarball'])
        dirname, basename = [pathname.dirname.to_s, pathname.basename.to_s]
        @nodes = {
          "name" => "build tarball",
          "target" => {
            "configure make make install" => "{build_dir}/{basename}",
            "prefix" => "/usr/local",
            "else" => "unzip"
          },
          "unzip" => {
            "unzip tarball" => "{build_dir}/{basename}",
            "else"          => "download"
          },
          "download" => {
            "tarball to"    => "{build_dir}/{basename}",
            "from"          => dirname,
            "get"           => basename
          }
        }
        self
      end
    end
  end
end
