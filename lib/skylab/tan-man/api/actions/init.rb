module Skylab::TanMan

  class API::Actions::Init < API::Action

    include TanMan::Services::FileUtils::InstanceMethods

    TanMan::Sub_Client[ self,
      :attributes,
        :boolean, :attribute, :dry_run,
        :required, :attribute, :local_conf_dirname,
          :default, API.local_conf_dirname,
        :required, :pathname, :attribute, :path, :default, -> { ::Dir.getwd } ]

    emits :all, error: :all, info: :all, skip: :info # etc

  private

    def dir
      @dir ||= path.join(local_conf_dirname)
    end

    def execute
      if dir.exist?
        if dir.directory?
          skip "already exists, skipping: #{ escape_path dir }"
        else
          error "is not a directory, must be: #{ escape_path dir }"
        end
      elsif ! path.exist?
        error "directory must exist: #{ escape_path path }"
      elsif path.file?
        error "path was file, not directory: #{ escape_path path }"
      elsif ! path.writable?
        error "cannot write, parent directory not writable: #{
          }#{ escape_path path }"
      else
        mkdir dir, :verbose => true, :noop => dry_run? # see svcs fu !
        emit :info, 'done.'
        true
      end
    end
  end
end
