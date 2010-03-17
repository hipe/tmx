require 'assess/code-builder'
require 'assess/uber-alles-array.rb'

module Hipe
  module Assess
    module DataMapper
      DmTypes = [ :Serial, :String, :DateTime, :Text ]
      ProtoTypesToNativeTypes = {
        :string    => :String,
        :date_time => :DateTime
      }
      include CodeBuilder::AdapterInstanceMethods
      extend self


      class ModelModuleSexp < CodeBuilder::ModuleSexp
        include CodeBuilder::RegistersConstants
        attr_reader :node_id
        def self.build(name,&block)
          thing = super(name)
          thing.my_initialize
          yield(thing) if block_given?
          thing
        end
        def my_initialize
          @node_id = CodeBuilder::Nodes.register(self)
        end
      end

      class ModelClassSexp < CodeBuilder::ClassSexp
        include CodeBuilder::AdapterInstanceMethods
        attr_reader :node_id
        def self.build(name,&block)
          if name =~ /:/
            fail("keeping our lives simple -- no deep names")
          end
          thing = super(name,nil,&nil)
          thing.my_initialize
          yield(thing) if block_given?
          thing
        end
        def constant_basename_symbol
          fail('oops') unless self[1].kind_of?(Symbol)
          self[1]
        end
        def my_initialize
          @node_id = CodeBuilder::Nodes.register(self)
          add_include 'DataMapper::Resource'
          dm_add_property :id, :Serial
        end
        def table_name_guess
          underscore(self.constant_basename_symbol.to_s)
        end
        def dm_add_property name, type
          fail('nah') unless name.kind_of?(::Symbol)
          fail('sorry') unless DmTypes.include?(type)
          block.push(
           s(:call, nil, :property,
             s(:arglist, s(:lit, name), s(:const, type))
            )
          )
        end

        def dm_add_association prototable, assoc
          case assoc.type
          when :many_to_many; dm_add_many_to_many(prototable, assoc)
          else fail("no: #{assoc.type}")
          end
          nil
        end

        def dm_add_belongs_to name_sym
          assert_type :name_sym, name_sym, Symbol
          block.push(
            s(:call, nil, :belongs_to, s(:arglist, s(:lit, name_sym)))
          )
          nil
        end

        def dm_add_has_n table_name_sym
          assert_type :table_name_sym, table_name_sym, Symbol
          block.push(
            s(:call,
             nil,
             :has,
             s(:arglist,
               s(:call, nil, :n, s(:arglist)), s(:lit, table_name_sym)))
          )
          nil
        end

        def dm_add_has_n_thru assoc_name_sym, thru_table_name_sym
          assert_type :assoc_name_sym, assoc_name_sym, Symbol
          assert_type :thru_table_name_sym, thru_table_name_sym, Symbol
          block.push(
            s(:call,
             nil,
             :has,
             s(:arglist,
              s(:call, nil, :n, s(:arglist)),
              s(:lit, assoc_name_sym),
              s(:hash, s(:lit, :through), s(:lit, thru_table_name_sym))))
          )
        end

        def dm_add_many_to_many prototable, assoc
          join_sexp = dm_add_or_get_join_table_sexp(prototable, assoc)
          other_table_name_sym = assoc.other_table(prototable).name.to_sym
          join_table_name_sym = join_sexp.table_name_guess.to_sym
          dm_add_has_n join_table_name_sym
          dm_add_has_n_thru other_table_name_sym, join_table_name_sym
        end

        def dm_add_or_get_join_table_sexp prototable, assoc
          other_name = assoc.other_table(prototable).name # str
          my_name = prototable.name
          names = [my_name, other_name].sort
          join_table_name = names.join('_')
          join_class_name = titleize(camelize(join_table_name))
          mod = self.parent_module
          if mod.has_constant? join_class_name.to_sym
            join_class_sexp = mod.get_constant join_class_name.to_sym
          else
            join_class_sexp = DataMapper.dm_build_join_class(
              join_class_name, names[0], names[1]
            )
            mod.add_constant_strict join_class_sexp
          end
          join_class_sexp
        end

        def parent_module= mod_sexp
          @parent_module_id = mod_sexp.node_id
        end

        def parent_module
          CodeBuilder::Nodes[@parent_module_id]
        end
      end

      def dm_build_join_class class_name, left_table_name, right_table_name
        klass = ModelClassSexp.build(class_name) do |k|
          k.dm_add_property :created_at, :DateTime
          k.dm_add_belongs_to left_table_name.to_sym
          k.dm_add_belongs_to right_table_name.to_sym
        end
        klass
      end

      def dm_build_entity_class mojule, prototable
        class_name = prototable.class_name_guess.to_sym
        fail("already has class named #{class_name}") if
          mojule.has_constant? class_name
        klass = ModelClassSexp.build(class_name.to_s)
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

      def generate_model_module_sexp_from_protomodel proto
        mojule = ModelModuleSexp.build('Whatever')
        proto.tables.each do |prototable|
          dm_build_entity_class mojule, prototable
        end
        mojule
      end
    end
  end
end
