require File.dirname(__FILE__)+'/schema-builder-sexps.rb'

module Hipe
  module Assess
    module DataMapper
      module SchemaBuilder
        include CommonInstanceMethods
        extend self

        def dm_build_join_class class_name, left_table_name, right_table_name
          klass = DmModelClassSexp.build(class_name) do |k|
            k.dm_add_property :created_at, :DateTime
            k.dm_add_property :updated_at, :DateTime
            k.dm_add_belongs_to left_table_name.to_sym
            k.dm_add_belongs_to right_table_name.to_sym
          end
          klass
        end

        def dm_build_entity_class mojule, prototable
          class_name = prototable.class_name_guess.to_sym
          fail("already has class named #{class_name}") if
            mojule.has_constant? class_name
          klass = DmModelClassSexp.build(class_name.to_s)
          klass.dm_add_property :created_at, :DateTime
          klass.dm_add_property :updated_at, :DateTime

          mojule.add_constant_strict klass
          klass.parent_module = mojule
          prototable.columns.each do |col|
            type = ProtoTypesToNativeTypes[col.type]
            klass.dm_add_property col.name.to_sym, type
          end
          prototable.associations.each do |assoc|
            klass.dm_add_association prototable, assoc
          end
          nil # we could return the sexp if we need to
        end

        def model_sexp_from_protomodel proto, app_name
          flail("bad app name") unless underscore?(app_name)
          module_name = titleize(camelize(app_name))
          mod = DmModelModuleSexp.build(module_name)
          mod.scope.block!.module!(:ModelInstanceMethods)
          mod.scope.block!.module!(:ModelClassMethods)
          proto.tables.each do |prototable|
            dm_build_entity_class mod, prototable
          end
          mod
        end
      end
    end
  end
end
