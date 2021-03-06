module Skylab::TaskExamples

  self._NOT_COVERED  # #todo

  class TaskTypes::BuildTarball < Home_.lib_.slake::Support::Execute_Graph

    attribute :build_tarball
    attribute :configure_with, :required => false

    def _task_init
      @interpolated or interpolate! or return false
      pathname = ::P_athname.new(build_tarball)
      dirname, basename_with_get_args = [pathname.dirname.to_s, pathname.basename.to_s]
      @basename = /\A([^?]+)/.match(basename_with_get_args)[1]
      @nodes = {
        "name" => "build tarball",
        "target" => {
          "configure make make install" => "{build_dir}/{basename}",
          "prefix" => "/usr/local",
          "else" => "unzip",
          "inherit attributes" => ['configure with', 'basename', 'show info']
        },
        "unzip" => {
          "unzip tarball" => "{build_dir}/{basename}",
          "else"          => "download",
          "inherit attributes" => ['basename', 'show info']
        },
        "download" => {
          "tarball to"    => "{build_dir}/{basename}",
          "from"          => dirname,
          "get"           => basename_with_get_args,
          'inherit attributes' => ['basename', 'show info']
        }
      }
      true
    end

    # children tasks reach up to this parent
    def basename
      @basename or fail("wtf")
    end

    def update_slake
      dependencies_update_slake or return false
      update_check true
    end

    def update_check slake=false
      slake or dependencies_update_check or return false
      old_url = Home_::Version.parse_string_with_version(build_tarball, :ui => ui)
      cu = Home_::CheckUpdate.new(build_tarball)
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
