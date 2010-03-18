require 'assess/util/sexpesque'
module Hipe
  module Assess
    module FrameworkCommon

      class AppInfo
        module MyClassMethods
          def new_with_defaults
            info = new
            info.init_with_defaults!
            info
          end

          # @todo
          def active_app_info
            new_with_defaults
          end
        end
        extend MyClassMethods

        attr_reader :app_root, :model, :controller, :server_executable
        def initialize
          @app_root = WishyWashyPath.new
          %w(model controller server_executable).each do |ivar|
            instance_variable_set("@#{ivar}", WishyWashyPath.new)
          end
        end

        def init_with_defaults!
          app_root.absolute_path = FileUtils.pwd
          model.relative_to = app_root
          model.relative_path = './model'
          model.might_be_plural = true
          model.might_be_folder = true
          model.might_have_extension = '.rb'
          controller.relative_to = app_root
          controller.relative_path = './controller'
          controller.might_be_plural = true
          controller.might_have_extension = '.rb'
          server_executable.relative_to = app_root
          server_executable.relative_path = './start.rb'
        end

        # @todo
        def version
          "0.0.0"
        end

        def name
          "(unnamed)"
        end

        def summary
          s = Sexpesque
          summary = s.new
          summary.push s[:app_root, app_root.summary]
          summary.push s[:model, model.summary]
          summary.push s[:controller, controller.summary]
          summary.push s[:server_executable, server_executable.summary]

          # push the ones that don't exist to the bottom
          summary.sort!{ |a,b| ( a[1][:exists][1] == :no ) ? 1 : -1 }

          summary.unshift s[:version, version]
          summary.unshift s[:name, name]

          summary
        end
      end
    end
  end
end
