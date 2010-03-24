require 'assess/code-builder'
require 'assess/util/uber-alles-array.rb'

module Hipe
  module Assess
    module DataMapper
      module DmAssocs; end # populated after we include dm-core

      DmTypes = [ :Serial, :String, :DateTime, :Text ]
      ProtoTypesToNativeTypes = {
        :string    => :String,
        :date_time => :DateTime
      }
      include CommonInstanceMethods
      extend self

      def schema_builder
        require File.dirname(__FILE__)+'/data-mapper/schema-builder.rb'
        SchemaBuilder
      end

      def orm_manager_singleton app_info
        require File.dirname(__FILE__)+'/data-mapper/orm-manager.rb'
        OrmManager.singleton_for_app_info(app_info)
      end

      def proto name
        File.join(RootDir,'lib/assess/code-adapter/data-mapper/proto',name)
      end

      def snippets
        CodeBuilder.get_file_sexp(proto('snippets.rb'))
      end
    end
  end
end
