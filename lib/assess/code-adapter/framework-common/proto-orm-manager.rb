require 'assess/util/sexpesque'
module Hipe
  module Assess
    module FrameworkCommon
      #
      # when the orm is unknown
      #
      class ProtoOrmManager
        @singles = {}
        class << self
          attr_accessor :singles
          def singleton app_info
            singles[app_info.app_info_id] ||= begin
              if app_info.model.exists?
                app_info.load_orm_manager_for_model
              else
                new(app_info)
              end
            end
          end
        end

        def initialize app_info
          @app_info = app_info
        end

        def db_check opts, *args
          s[:db_check,
            s[:ok, false],
            s[:model_path, app_info.model.pretty_path],
            s[:exists, app_info.model.exists?],
            s[:messages,
              "model path it's not exist",
              "can't determine database info (e.g. orm) without a model path"
            ]
          ]
        end

        def merge_data ui, *a
          ui.puts s[:fail,
            s[:messages,
              "model not found: #{app_info.model.pretty_path}"
            ]
          ].jsonesque
          nil
        end

        def migrate ui, *a
          ui.puts s[:fail,
            s[:messages,
              "can't migrate without a model: #{app_info.model.pretty_path}"
            ]
          ].jsonesque
        end

      private
        def app_info; @app_info end # avoid warnings
        def s; Sexpesque; end
      end
    end
  end
end
