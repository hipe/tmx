require 'assess/util/uber-alles-array.rb'
require 'assess/code-adapter/framework-common/wishy-washy-path'
require 'assess/code-adapter/framework-common/app-info'


module Hipe
  module Assess
    module FrameworkCommon
      class << self
        def dispatch_migrate ui, opts
          AppInfo.current.orm_manager.migrate ui, opts
        end
        def dispatch_merge_data ui, sin, opts
          AppInfo.current.orm_manager.merge_json_data ui, sin, opts
        end
        def dispatch_db_check opts, *args
          AppInfo.current.orm_manager.db_check opts, *args
        end
        def tmpdir_for name
          @tmpdir_for ||= {}
          @tmpdir_for[name] ||= begin
            aip = AppInfo.current.persistent
            found_dir = nil
            if aip['last_temp_dir']
              last_temp_dir = aip['last_temp_dir'][1]
              found_dir = last_temp_dir if File.exist?(last_temp_dir)
            end
            if ! found_dir
              found_dir = File.join(CodeBuilder.tmpdir, name)
              aip['last_temp_dir'] = found_dir
            end
            found_dir
          end
        end
      end
    end
  end
end
