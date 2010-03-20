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
      end
    end
  end
end
