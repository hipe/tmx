require 'ruby-debug'
require 'assess/util/uber-alles-array' # associative array
require 'assess/proto/type'
require 'assess/util/strict-attr-accessors'
require 'assess/code-builder'

module Hipe
  module Assess
    module Proto

      module JsonesqueToSummary
        def summary
          jsonesque(str = StringIO.new)
          str.seek(0)
          str.read
        end
      end

      class Model
        extend UberAllesArray
        attr_reader :model_id, :tables
        def initialize
          @model_id = self.class.register(self)
          @tables = AssArr.new
        end
        def create_and_add_table table_name
          table = Table.new table_name
          table.model = self
          @tables.push_with_key table, table.name
          table
        end
        def jsonesque
          jsonesque_write_to(str = StringIO.new)
          str.seek(0)
          str.read
        end
        def jsonesque_write_to out
          out.print '['
          last = @tables.size - 1
          @tables.each_with_index do |table, idx|
            table.jsonesque_write_to(out)
            out.print(",\n") unless idx==last
          end
          out.puts ']'
          nil
        end
        include JsonesqueToSummary
      end

      class Table
        extend UberAllesArray, StrictAttrAccessors
        include CommonInstanceMethods
        string_attr_accessor :name
        attr_reader :table_id, :columns
        def initialize(name)
          self.name = name
          @table_id = self.class.register(self)
          @columns = AssArr.new
          @association_ids = []
        end
        def class_name_guess
          titleize(camelize(name))
        end
        def model= model
          @model_id = model.model_id
        end
        def model
          Model.all[@model_id]
        end
        def create_and_add_data_column name, type
          column = DataColumn.new name, type
          @columns.push_with_key column, column.name
        end
        def add_association assoc
          @association_ids.push assoc.association_id
          nil
        end
        def associations
          @association_ids.map do |id|
            Association.all[id]
          end
        end
        def jsonesque
          jsonesque_write_to(str = StringIO.new)
          str.seek(0)
          str.read
        end
        def jsonesque_write_to out
          str = "{\n  \"type\":\"table\",\n"
          str << "  \"name\":#{name.to_json},\n"
          assoc_to_json(str)
          columns_to_json(str)
          str << "\n}"
          out.print str
          nil
        end
        include JsonesqueToSummary

        def columns_to_json s
          ss = []
          @columns.each do |col|
            col.jsonesque_write_to(sss='')
            ss.push "#{col.name.to_json}:#{sss}"
          end
          s << ",\n  \"columns\":["
          if ss.any?
            s << "\n    "
            s << ss.join(",    ")
            s << "]"
          else
            s << "]"
          end
          s
        end
        def assoc_to_json s
          collection_to_json 'associations', s
        end
        def collection_to_json name, s
          s << "  \"#{name}\":["
          ss = []
          collection = send(name)
          collection.each do |item|
            item.jsonesque_write_to(sss='', self)
            ss << sss
          end
          if ss.any?
            s << "\n    "
            s << (ss.join(",\n    "))
            s << "]"
          else
            s << "]"
          end
        end
      end

      class DataColumn
        extend UberAllesArray, StrictAttrAccessors
        string_attr_accessor :name
        symbol_attr_accessor :type
        attr_reader :column_id
        def initialize name, type
          self.name = name
          self.type = type
          @column_id = self.class.register(self)
        end
        def jsonesque_write_to(io)
          fake = {:type => type}
          io << fake.to_json
        end
        include JsonesqueToSummary
      end

      class Association
        Types = [:many_to_many, :belongs_to, :has_many]
        attr_accessor :type, :association_id
        extend UberAllesArray
        def initialize type, left, right
          fail "bad type: #{type}" unless Types.include?(type)
          @type = type
          @left_table_id = left.table_id
          @right_table_id = right.table_id
          @association_id = self.class.register(self)
        end
        %w(left right).each do |hand|
          ivar_name = "@#{hand}_table_id"
          method_name = "#{hand}_table"
          define_method(method_name) do
             Table.all[instance_variable_get(ivar_name)]
          end
        end
        class << self
          def associate type, left_table, right_table
            assoc = Association.new(type, left_table, right_table)
            case type
            when :many_to_many
              left_table.add_association assoc
              right_table.add_association assoc
            when :belongs_to
              left_table.add_association assoc
              assoc2 = Association.new(:has_many, right_table, left_table)
              right_table.add_association assoc2
            else
              fail("no: #{type.inspect}")
            end
            nil
          end
        end
        def other_table this_table
          other_table = case true
          when this_table.table_id == @left_table_id then right_table
          when this_table.table_id == @right_table_id then left_table
          else fail("association not associated with table!?"); end
          other_table
        end
        def jsonesque_write_to io, from_table
          to_table = other_table from_table
          io << %{{"type":"#{type.to_sym}","table":"#{to_table.name}"}}
          nil
        end
        include JsonesqueToSummary
      end
    end
  end
end
