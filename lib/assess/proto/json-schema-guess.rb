require 'json'
require 'assess/proto/model'

module Hipe
  module Assess
    module JsonSchemaGuess
      extend self

      class FieldMetrics
        attr_reader :name, :distinct,:type_guess, :many
        alias_method :many?, :many
        def initialize name
          @name = name
          @distinct = Hash.new{|h,k| h[k] = 0}
          @many = false
          @type_guess = nil
        end

        def summary
          x = {}
          if distinct.size != 0
            x.merge!(
              :max_repeat_times => max_repeat,
              :distinct => distinct.size,
              :most_popular_summary => most_popular_summary,
              :type_guess => @type_guess.nil? ? nil : @type_guess.to_sym
            )
          end
          if many
            x[:child] = many_guy.guy_summary
          end
          x
        end
        def distinct_flip
          thing = []
          distinct.each do |(k,v)|
            thing.push [v, k]
          end
          thing.sort!{|a,b| b[0] <=> a[0] }
          thing
        end
        MaxLineWidthSorta = 300
        TruncateAmt = 70
        MaxWhatever = 3
        def truncate(str,len)
          if str.length <= len
            str
          else
            '..' + str[-1 * len .. -1]
            # str[0..len-3] + '..'
          end
        end
        def repeats
          distinct_flip.select do |(count, value)|
            count > 1
          end
        end
        def non_empty_repeats
          repeats.reject do |(count, value)|
            value.empty?
          end
        end
        def most_popular_summary
          flip = distinct_flip
          tots = 0
          sub_flip = []
          ct = 0
          while(flip.any?)
            str = truncate(flip.first[1],TruncateAmt)
            ct += 1
            break if str.length + tots > MaxLineWidthSorta
            break if ct > MaxWhatever
            poppers = flip.shift
            poppers[1] = str
            tots += str.length
            sub_flip.push sprintf("%s=>'%s'",poppers[0],poppers[1])
          end
          sub_flip
        end
        def max_repeat
          distinct.values.max
        end
        def many_guy
          @many_guy ||= begin
            EntityMetrics.new
          end
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
            @distinct[value] += 1
            deal_with_type value
          end
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

      class EntityMetrics < Hash
        def initialize
          super{|h,k| h[k] = FieldMetrics.new(k) }
        end
        def guy_summary
          Hash[ * self.to_enum.map{|k,v|
            [ k,
              v.summary
            ]
          }.flatten ]
        end
      end

      def analyze sin, sout
        metrics = self.entity_metrics sin
        sout.puts JSON.pretty_generate( metrics.guy_summary )
      end

      def new_single_column_prototable model, field, table_name
        table = model.create_and_add_table table_name
        table.create_and_add_data_column field.name, field.type_guess.to_sym
        table
      end

      def new_prototable_from_entity_metrics model, metrics, entity_name
        table = model.create_and_add_table(entity_name)
        metrics.each do |(name,field)|
          new_prototable_or_column model, table, field
        end
        table
      end

      def new_prototable_or_column model, table, field
        if field.non_empty_repeats.any? || field.many # this is the key
          if field.many?
            # this field is definately another table
            metrics = field.many_guy
            new_table = new_prototable_from_entity_metrics(
              model, metrics, field.name
            )
            Proto::Association.associate(
              :many_to_many,
              table,
              new_table
            )
          else
            # we have a field that has values that repeat.
            # make new table and many to many
            new_table = new_single_column_prototable(
              model, field, "#{table.name}_#{field.name}"
            )
            Proto::Association.associate(
              :many_to_many,
              table,
              new_table
            )
          end
        else
          # this field as no (non emtpy) repeats.  add a field
          table.create_and_add_data_column(
            field.name, field.type_guess.to_sym
          )
        end
      end

      def protomodel_from_metrics metrics, entity_name
        model = Proto::Model.new
        new_prototable_from_entity_metrics(
          model, metrics, entity_name)
        model
      end

      def protomodel sin, sout, entity_name
        metrics = self.entity_metrics sin
        model = protomodel_from_metrics metrics, entity_name
        model.jsonesque(sout)
        nil
      end

      def entity_metrics sin
        json_str = sin.read
        structo = JSON.parse json_str
        metrics = EntityMetrics.new
        structo.each do |row|
          row.each do |(k,v)|
            metrics[k].eat v
          end
        end
        metrics
      end
    end
  end
end
