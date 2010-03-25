require 'json'
require 'assess/proto/model'
require 'assess/util/sexpesque'

module Hipe
  module Assess
    module JsonSchemaGuess
      extend self

      def process_analyze_request sin, sout
        summary = analyze sin
        sout.write summary.jsonesque
      end

      def analyze sin
        metrics = entity_metrics sin
        summary = metrics.entity_summary
        summary
      end

      def process_protomodel_request sin, sout, entity_name
        metrics = self.entity_metrics sin
        model = protomodel_from_metrics metrics, entity_name
        sout.write model.jsonesque
        nil
      end

      def entity_metrics sin
        json_str = sin.read
        structo = JSON.parse json_str
        metrics = EntityMetrics.new
        structo.each do |row|
          row.each do |(field,value)|
            metrics[field].eat value
          end
        end
        metrics
      end

      def protomodel_from_metrics metrics, entity_name
        model = Proto::Model.new
        new_prototable_from_entity_metrics(
          model, metrics, entity_name)
        model
      end

    private

      def s; Sexpesque; end

      class FieldMetrics
        attr_reader :name, :type_guess, :many
        alias_method :many?, :many
        def initialize name
          @name = name
          @counts = nil
          @many = false
          @type_guess = nil
        end

        def counts
          @counts ||= Hash.new{|h,k| h[k] = 0}
        end

        def eat value
          if value.kind_of?(Hash)
            @many = true
            value.each do |(k,v)|
              many_guy[k].eat v
            end
          elsif value.kind_of?(Array)
            @many = true
            value.each do |v|
              eat v
            end
          else
            counts[value] += 1
            deal_with_type value
          end
        end

        def field_summary
          resp = s[:field_summary]
          if counts.any?
            resp.push s[:nonblank_sample_size, nonblank_sample_size]
            resp.push s[:percent_nonblank, "%%%02.2f" % [percent_nonblank]]
            resp.push s[:width,
              "%d distinct nonblank values" % [num_distinct_nonblank_values] ]
            resp.push s[:height_factor,
              ( "%%%02.2f of nonblank values are of values that repeat" %
              [height_factor] )
            ]
            resp.push s[:num_distinct_repeated_nonblank_values,
              num_distinct_repeated_nonblank_values
            ]
            resp.push s[:type_guess, type_guess.to_sym]
            resp.push s[:most_popular_values, most_popular_summary_lines]
          elsif ! many?
            resp.push s[:nonblank_sample_size, 0]
          end
          if many?
            resp.push s[:child, many_guy.entity_summary]
          end
          resp
        end
        # what percent of nonblank values are values that repeat?
        def height_factor
          tots = 0
          these = 0
          counts.each do |(value, count)|
            next if Blank =~ value
            tots += count
            these += count if count > 1
          end
          resp = (tots == 0) ? :Nan : (these.to_f / tots.to_f * 100)
          resp
        end
        def many_guy
          @many_guy ||= begin
            EntityMetrics.new
          end
        end
      private
        def s; Sexpesque; end
        Blank = /\A[[:space:]]*\Z/
        def blanks_exist?
          counts.keys.any?{|value| Blank =~ value}
        end
        def percent_nonblank
          tots = 0
          nonblanks = 0
          counts.each do |(value, count)|
            tots += count
            nonblanks += count if Blank !~ value
          end
          resp = (tots == 0) ? :Nan : (nonblanks.to_f/tots.to_f * 100)
          resp
        end
        def nonblank_sample_size
          count = 0
          counts.each do |(value, count2)|
            next if Blank =~ value
            count += count2
          end
          count
        end
        AGobletOfData = 300
        DefaultTruncateAmt = 70
        MaxTopRows = 3
        def truncate(str,len=DefaultTruncateAmt)
          if str.length <= len
            str
          else
            '..' + str[-1 * len .. -1]
            # str[0..len-3] + '..'
          end
        end
        def num_distinct_nonblank_values
          counts.keys.count{|value| Blank !~ value}
        end
        def num_distinct_repeated_nonblank_values
          counts.map.count{|(v,c)| Blank !~ v && c > 1 }
        end
        def repeat_pairs
          counts.select do |(value, count)|
            count > 1
          end
        end
        def nonblank_repeat_pairs
          repeat_pairs.reject do |(value, count)|
            Blank =~ value
          end
        end
        def most_popular_summary_lines
          sorted = counts.sort{|a,b| b[1] <=> a[1]}
          top_lines = []
          num_rows = 0
          tot_str_len = 0
          sorted.each do |(value, count)|
            str = truncate(value)
            tot_str_len += str.length
            break if tot_str_len > AGobletOfData
            top_lines.push sprintf("%s times => '%s'",count,str)
            num_rows += 1
            break if num_rows >= MaxTopRows
          end
          top_lines
        end
        def max_repeat
          counts.values.max
        end
        def deal_with_type value
          type = Proto::Type.of_string(value)
          if type == Proto::Type::Empty
            # for now we just ignore all these
          elsif @type_guess.nil?
            if Proto::Type::Empty != type
              @type_guess = type
            end
          else
            if type.can_be_represented_with?(@type_guess)
              # type guess covers the type
            elsif @type_guess.can_be_represented_with?(type)
              @type_guess = type
            else
              raise AppFail.new('pefectly reasonable logic fail')
            end
          end
        end
      end

      class EntityMetrics
        attr_reader :order
        def initialize
          @hash = Hash.new{|h,k| h[k] = FieldMetrics.new(k) }
          @order = []
        end

        def [](field)
          @order.push(field) unless @hash.has_key?(field)
          @hash[field]
        end

        def entity_summary
          s[:fields_summary, * @order.map{ |field|
            s[field.intern, @hash[field].field_summary]
          }]
        end

        def each_field
          @hash.each do |(field, metrics)|
            yield([field,metrics])
          end
        end
      private
        def s; Sexpesque end
      end

      def new_single_column_prototable model, field, table_name
        table = model.create_and_add_table table_name
        table.create_and_add_data_column field.name, field.type_guess.to_sym
        table
      end

      def new_prototable_from_entity_metrics model, metrics, entity_name
        table = model.create_and_add_table(entity_name)
        metrics.each_field do |(name,field)|
          new_prototable_or_column model, table, field
        end
        table
      end

      def new_prototable_or_column model, table, field
        # this is the key
        hf = field.height_factor
        if :Nan==hf && !field.many?
          debugger; 'wtf? step into this one'
          field.height_factor
        end
        if field.many? || hf > 0
          if field.many?
            # this field is definately another table, because of the
            # structure of the source data.  We definately have many of it
            # and it is likely (why?) that it has many of us.
            # (this could be verified in the analysis phase but whatever)
            metrics = field.many_guy
            new_table = new_prototable_from_entity_metrics(
              model, metrics, field.name
            )
            Proto::Association.associate(
              :many_to_many,
              table,
              new_table
            )
            nil
          else
            # we have a column that has values that repeat during the lifetime
            # of all the known data.  Because they repeat they belong in a
            # separate table, but since each row only pointed to one such
            # entity (as this is not field.many? above), it is a belongs to.
            foreign = new_single_column_prototable(
              model, field, "#{table.name}_#{field.name}"
            )
            Proto::Association.associate(
              :belongs_to,
              table,
              foreign
            )
            nil
          end
        else
          # this field has no (non emtpy) repeats.  add a field
          table.create_and_add_data_column(
            field.name, field.type_guess.to_sym
          )
        end
      end
    end
  end
end
