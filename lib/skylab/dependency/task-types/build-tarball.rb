require File.expand_path('../../task', __FILE__)
require 'pathname'

module Skylab
  module Dependency
    class TaskTypes::BuildTarball < Graph

      attribute :build_tarball
      attribute :configure_with, :required => false

      def initialize a, b
        task_orig_initialize a, b # skip up to grandparent!
      end

      def _task_init
        @interpolated or interpolate! or return false
        pathname = Pathname.new(build_tarball)
        dirname, @basename = [pathname.dirname.to_s, pathname.basename.to_s]
        @nodes = {
          "name" => "build tarball",
          "target" => {
            "configure make make install" => "{build_dir}/{basename}",
            "prefix" => "/usr/local",
            "else" => "unzip",
            "basename" => @basename,
            "inherit attributes" => ["configure with", "show info"]
          },
          "unzip" => {
            "unzip tarball" => "{build_dir}/{basename}",
            "else"          => "download",
            "basename"      => @basename
          },
          "download" => {
            "tarball to"    => "{build_dir}/{basename}",
            "from"          => dirname,
            "get"           => @basename
          }
        }
        true
      end

      def update_slake
        dependencies_update_slake or return false
        update_check true
      end

      def update_check slake=false
        slake or dependencies_update_check or return false
        require File.expand_path('../../check-update', __FILE__)
        old_url = Version.parse_string_with_version(build_tarball, :ui => ui)
        cu = CheckUpdate.new(build_tarball)
        if new_url = cu.run(ui)
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
          note = "(looked for #{cu.versions_not_found.join(', ')})"
          if slake
            v = old_v ? " of #{old_v}" : nil
            _info "No updates found #{note}. Attemping normal install#{v}.."
            self.slake
          else
            if old_v
              _info "Nothing newer than #{old_v} found #{note}."
            else
              _info "Failed to determine version from url."
            end
          end
        end
      end
    end
  end
end

