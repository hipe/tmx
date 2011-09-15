require File.expand_path('../../task', __FILE__)
require 'pathname'

module Skylab
  module Dependency
    class TaskTypes::BuildTarball < Graph

      attribute :build_tarball

      def initialize a, b
        task_initialize a, b # skip up to grandparent!
      end

      def _task_init
        @interplated or interpolate! or return false
        pathname = Pathname.new(build_tarball)
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
        true
      end
    end
  end
end
