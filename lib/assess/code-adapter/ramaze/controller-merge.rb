module Hipe
  module Assess
    module Ramaze
      module ControllerMerge
        extend self
        include CommonInstanceMethods
        def controller_merge ui, opts, model_name
          if (!Ramaze.app_info.server_executable.exists? ||
            opts.prune?
          )
            require 'assess/code-adapter/ramaze/app-init.rb'
            AppInit::app_init(ui, opts)
          end
          puts "in controller merge do something"
        end
      end
    end
  end
end