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

      def update_slake
        update_check true
      end

      def update_check slake=false
        require File.expand_path('../../check-update', __FILE__)
        old_url = Version.parse_string_with_version(build_tarball, :ui => ui)
        if new_url = CheckUpdate.new(build_tarball).run(ui)
          old_ver = old_url.detect(:version).to_s
          new_ver = new_url.detect(:version).to_s
          msg = "#{yelo 'OHAI:'} found version #{bold new_ver} that is newer than what is on record: #{bold old_ver}"
          if slake
            _info "#{msg}. Attempting to install.."
            @build_tarball = new_url.to_s
            @task_initted or task_init # strange but good that this hasn't happened yet
            self.slake
          else
            _info "#{msg}."
          end
        else
          old_v = old_url ? old_url.detect(:version).to_s : nil
          if slake
            v = old_v ? " of #{old_v}" : nil
            _info "No updates found.  Attemping normal install#{v}.."
            self.slake
          else
            if old_v
              _info "Nothing newer than #{old_v} found."
            else
              _info "Failed to determine version from url."
            end
          end
        end
      end
    end
  end
end

