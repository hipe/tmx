module Skylab::TMX::Modules::Bleed::API
  class Actions::Path < Action
    emits :path # note this is not added to the 'all' network (no touching hacks needed)
    def get_path
      path = config_get_path and emit(:path, path)
    end
    def invoke
      config_read or return false
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


