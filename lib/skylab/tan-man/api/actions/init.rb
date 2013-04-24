module Skylab::TanMan

  class API::Actions::Init < API::Action
    extend API::Action::Attribute_Adapter


    include TanMan::Services::FileUtils::InstanceMethods

    attribute :dry_run, boolean: true
    attribute :local_conf_dirname, required: true,
                default: API.local_conf_dirname
    attribute :path, pathname: true, required: true,
                default: ->{ ::Dir.getwd }

    emits :all, error: :all, info: :all, skip: :info # etc

  protected

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
