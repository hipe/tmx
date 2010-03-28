require 'assess/util/sexpesque'
here = File.dirname(__FILE__)
require here + '/abstract-model-interface.rb'
require here + '/dm-model-extra.rb'

module Hipe
  module Assess
    module DataMapper

      #
      # the orm-manager is called by the command line controller
      # to implement services like data merge and schema migrations.
      # Its focus is to know (or guess) how to convert data structures like
      # arrays and hashes into ORM resource objects, given the model
      # class's relationships.
      #
      # The orm-manager is distinct from the schema-builder in that
      # it requires that the datamodel exist as DataMapper-specific
      # ruby code.

      class OrmManager
        include CommonInstanceMethods
        @singles = {}
        class << self
          def singleton_for_app_info app_info
            @singles[app_info.app_info_id] ||= new(app_info)
          end
        end
        def initialize app_info
          @app_info = app_info
        end
        private :initialize
        def process_migrate_request ui, opts
          setup!(ui) unless setup?
          models.each do |(k,table)|
            table.auto_migrate!
          end
        end
        def models
          abstract_model_interface.model
        end
        def join_model_for *a
          abstract_model_interface.join_model_for(*a)
        end
        def process_merge_data_request ui, sin, opts
          setup!(ui) unless setup?
          abstract_model_interface.load_model_with_sexp_reflection
          abstract_model_interface.main_model_name = opts.model_name
          require File.dirname(__FILE__)+'/drunken-merge.rb'
          DrunkenMerge.process_merge_json_request self, ui, sin, opts
        end
        def db_check opts, *args
          Sexpesque[
            :db_check,
            app_info.model.summary,
            app_info.database_summary
          ]
        end
        def abstract_model_interface
          @abstract_model_interface ||= begin
            AbstractModelInterface.new(app_info)
          end
        end

      private

        attr_reader :app_info

        def setup?; @setup end

        def setup!(ui = nil)
          fail('no') if @setup
          require 'dm-core'
          require 'dm-aggregates'
          ::DataMapper::Logger.new(ui || $stdout, :debug)
          sqlite_db = app_info.active_db_path.pretty_path
          ::DataMapper.setup(:default, "sqlite3:#{sqlite_db}")
          set_naming_convention
          require app_info.model.path
          @setup = true
        end

        # this could go in the model type thing? it should be visible etc
        def set_naming_convention
          repository(:default).adapter.
            resource_naming_convention = lambda do |value|
              underscore(class_basename(value))
          end
        end
      end
    end
  end
end
