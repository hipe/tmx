require File.dirname(__FILE__)+'/schema-builder-sexps.rb'

module Hipe
  module Assess
    module DataMapper
      module SchemaBuilder
        include CommonInstanceMethods
        extend self

        def model_sexp_from_protomodel proto, app_name
          flail("bad app name") unless underscore?(app_name)
          module_name = titleize(camelize(app_name))
          mod = DmModelModuleSexp.build(module_name)
          node = DataMapper.snippets.codepath('module:ModelCommon')
          mod.scope.block!.add_child(node)
          proto.tables.each do |prototable|
            dm_build_entity_class mod, prototable
          end
          file = add_requires(mod)
          file
        end

        def dm_build_join_class class_name, left_table_name, right_table_name
          klass = DmModelClassSexp.build(class_name) do |k|
            k.dm_add_belongs_to left_table_name.to_sym
            k.dm_add_belongs_to right_table_name.to_sym
          end
          klass
        end

      private

        def add_requires mod
          block = CodeBuilder::BlockeySexp[s(:block)].deep_enhance!
          block.insert_node_at(1, mod)
          block.insert_code_at(1, 'require "dm-core"')
          block.insert_code_at(2, 'require "dm-timestamps"')
          block
        end

        def dm_build_entity_class mod, prototable
          class_name = prototable.class_name_guess.to_sym
          fail("already has class named #{class_name}") if
            mod.has_constant? class_name
          klass = DmModelClassSexp.build(class_name.to_s)

          mod.add_constant_strict klass
          klass.parent_module = mod
          prototable.columns.each do |col|
            type = ProtoTypesToNativeTypes[col.type]
            klass.dm_add_property col.name.to_sym, type
          end
          prototable.associations.each do |assoc|
            klass.dm_add_association prototable, assoc
          end
          nil # we could return the sexp if we need to
        end
      end
    end
  end
end
