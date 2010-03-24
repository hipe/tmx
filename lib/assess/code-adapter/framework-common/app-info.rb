require 'assess/util/sexpesque'
require 'assess/code-builder'
require 'assess/util/persistent-node'
module Hipe
  module Assess
    module FrameworkCommon
      class AppInfo
        include CommonInstanceMethods

        module MyClassMethods
          def new_with_defaults
            info = new
            info.init_with_defaults!
            info
          end

          # @todo
          def current
            @app_info ||= new_with_defaults
          end

          def all; @all ||= [] end

        end
        extend MyClassMethods


        attr_reader :app_root, :model, :controller, :server_executable,
                    :active_db_path, :app_info_id, :persistent

        def initialize
          @app_info_id = self.class.all.length
          self.class.all[@app_info_id] = self
          @app_root = WishyWashyPath.new(:app_root)
          %w(model controller server_executable active_db_path).each do |ivar|
            instance_variable_set("@#{ivar}", WishyWashyPath.new(ivar))
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
          active_db_path.relative_to = app_root
          active_db_path.relative_path = './db'
          @persistent = PersistentNode.create_or_get(
            File.join(app_root.pretty_path,'.assess.json')
          )
        end

        # @todo
        def version
          "0.0.0"
        end

        def name
          "(unknown)"
        end

        def has_model?
          model.exists?
        end

        def orm_manager
          require File.dirname(__FILE__)+'/proto-orm-manager.rb'
          ProtoOrmManager.singleton(self) # will flip back around
        end

        def load_orm_manager_for_model
          orm_name_sym = guess_orm_from_model
          mgr = load_orm_manager_for_orm(orm_name_sym)
          mgr
        end

        def summary
          summary = s[]
          summary.push s[:app_root, app_root.summary]
          summary.push s[:model, model.summary]
          summary.push s[:controller, controller.summary]
          summary.push s[:server_executable, server_executable.summary]

          summary.push s[:db, database_summary]

          # push the ones that don't exist to the bottom
          summary.sort!{ |a,b| ( a[1][:exists][1] == :no ) ? 1 : -1 }

          summary.unshift s[:version, version]
          summary.unshift s[:name, name]

          summary
        end


        def database_summary
          active_db_path.summary
        end


      private

        def load_orm_manager_for_orm name_sym
          req = "assess/code-adapter/#{fileize(name_sym)}"
          require req
          cls = titleize(camelize(name_sym))
          mod = Assess.const_get(cls)
          mod.orm_manager_singleton(self)
        end

        SupremeHackRe = /(DataMapper::Resource)/
        def guess_orm_from_model
          if model.single_file?
            all = File.read(model.path)
            md = SupremeHackRe.match(all)
            if ! md
              return flail("failed to guess orm")
            end
            orm = nil
            if md[1]
              orm = :data_mapper
            else
              fail("huh? error asdf")
            end
            orm
          else
            flail("sorry. not implemented yet for multi-file models.")
          end
        end

        def s; Sexpesque end
      end
    end
  end
end
