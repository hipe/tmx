module Hipe
  module Assess
    module DataMapper
      module SchemaBuilder

        #
        # a lot of this has been replaced by better logic
        # in codebuilder.  check it out if u need to change things
        #

        class DmModelModuleSexp < CodeBuilder::ModuleSexp
          include CodeBuilder::RegistersConstants # deprecated
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

        class DmModelClassSexp < CodeBuilder::ClassSexp
          include CommonInstanceMethods
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
            if self[1].kind_of?(Symbol)
              self[1]
            elsif self[1].first == :const
              self[1][1]
            else
              debugger; 'x'
            end
          end
          def my_initialize
            @node_id = CodeBuilder::Nodes.register(self)
            add_include 'DataMapper::Resource'
            add_extend  'ModelClassMethods'
            add_include 'ModelInstanceMethods'
            dm_add_property :id, :Serial
          end
          def table_name_guess
            underscore(self.constant_basename_symbol.to_s)
          end
          def dm_add_property name, type
            fail('nah') unless name.kind_of?(::Symbol)
            fail('sorry') unless DmTypes.include?(type)
            scope.block!.push(
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
            scope.block!.push(
              s(:call, nil, :belongs_to, s(:arglist, s(:lit, name_sym)))
            )
            nil
          end

          def dm_add_has_n table_name_sym
            assert_type :table_name_sym, table_name_sym, Symbol
            scope.block!.push(
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
            scope.block!.push(
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
            join_sexp = dm_join_table!(prototable, assoc)
            other_table_name_sym = assoc.other_table(prototable).name.to_sym
            join_table_name_sym = join_sexp.table_name_guess.to_sym
            dm_add_has_n join_table_name_sym
            dm_add_has_n_thru other_table_name_sym, join_table_name_sym
          end

          def dm_join_table! prototable, assoc
            other_name = assoc.other_table(prototable).name # str
            my_name = prototable.name
            names = [my_name, other_name].sort
            join_table_name = names.join('_')
            join_class_name = titleize(camelize(join_table_name))
            mod = self.parent_module
            if mod.has_constant? join_class_name.to_sym
              join_class_sexp = mod.get_constant join_class_name.to_sym
            else
              join_class_sexp = SchemaBuilder.dm_build_join_class(
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
      end
    end
  end
end
