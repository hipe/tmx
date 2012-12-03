require 'fileutils'

module Skylab::TanMan

  class API::Actions::Init < API::Action
    extend API::Action::Attribute_Adapter

    include ::FileUtils

    attribute :dry_run, boolean: true
    attribute :local_conf_dirname, required: true, default: API.local_conf_dirname
    attribute :path, pathname: true, required: true, default: ->{ ::FileUtils.pwd }

    emits :all, error: :all, info: :all, skip: :info # etc

  protected

    def dir
      @dir ||= path.join(local_conf_dirname)
    end

    def execute
      if dir.exist?
        if dir.directory?
          skip "already exists, skipping: #{dir.pretty}"
        else
          error "is not a directory, must be: #{dir.pretty}"
        end
      elsif ! path.exist?
        error "directory must exist: #{path.pretty}"
      elsif path.file?
        error "path was file, not directory: #{path.pretty}"
      elsif ! path.writable?
        error "cannot write, parent directory not writable: #{path.pretty}"
      else
        mkdir dir.to_s, :verbose => true, :noop => dry_run?
        emit :info, 'done.'
        true
      end
    end

    def fu_output_message msg
      emit :info, msg
    end
  end
end
