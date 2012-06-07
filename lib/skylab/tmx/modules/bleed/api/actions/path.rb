module Skylab::Tmx::Modules::Bleed::Api
  class Actions::Path < Action
    emits :path # note this is not added to the 'all' network (no touching hacks needed)
    def get_path
      (o = config['bleed']) or return error("section not found in #{config.pretty}: [bleed]")
      (path = o['path']) or return error("'path' attribute not found in [bleed] in #{config.pretty}")
      emit :path, path
    end
    def invoke
      config.exist? or return error("#{config.pretty} not found, use 'init' to create.")
      config.read do |o|
        o.on_all { |e| emit(:error, "issue reading config file: #{e.type}: #{e.message}") }
      end or return false
      params[:path] ? set_path : get_path
    end
    def set_path
      config['bleed'] ||= {} # create the section called [bleed]
      path = contract_tilde(File.expand_path(params[:path]))
      prev_path = config['bleed']['path']
      if prev_path == path
        emit :info, "no change to path (#{path})"
        nil
      else
        if prev_path
          emit :info, "changing bleed.path from #{prev_path.inspect} to #{path.inspect}"
        else
          emit :info, "adding bleed.path value to file: #{path.inspect}"
        end
        config['bleed']['path'] = path
        config_write
      end
    end
  end
end


