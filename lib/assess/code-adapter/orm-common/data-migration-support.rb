require 'assess/util/sexpesque'

module Hipe
  module Assess
    module OrmCommon
      module Util
        include CommonInstanceMethods
        extend self

        Scalars = [NilClass, TrueClass, FalseClass, Fixnum, Float, String]

        def is_scalar? mixed
          Scalars.detect{|cls| mixed.kind_of?(cls)}
        end

        def my_get_type mixed
          if is_scalar? mixed then :scalar
          elsif mixed.kind_of?(Hash) then :hash
          elsif mixed.kind_of?(Array) then :array
          else fail("sorry, unsupporeted type: #{mixed}:#{mixed.class}"); end
        end
      end

      module Counts
        class Count < Struct.new(
          :model_name, :created, :retrieved, :net_inserted, :before, :after
        );
          def s; Sexpesque; end
          def summary
            s[ model_name,
              s[:model, model_name ],
              s[:before,before],
              s[:after, after],
              s[:net_inserted, net_inserted],

              s[:retrieved, retrieved]
            ]
          end
        end

        def set_count_for which
          orm.abstract_model_interface.model.each do |(key_sym,model)|
            @counts[key_sym].send("#{which}=", model.count)
            yield(@counts[key_sym]) if block_given?
          end
        end

        def do_before_counts
          @counts = Hash.new{|h,k| h[k] = Count.new(k,0,0,nil,nil,nil)}
          set_count_for :before
        end

        def increment_retrieved model
          sym = model.name_sym
          @counts[sym].retrieved += 1
        end

        def increment_created model
          sym = model.name_sym
          @counts[sym].created += 1
        end

        def do_after_counts(ui)
          set_count_for(:after) do |count|
            count.net_inserted = count.after - count.before
          end
          re = /_/
          ks = @counts.keys.sort do |a,b|
            a, b = [a.to_s, b.to_s]
            a1, b1 = [a.scan(re).size, b.scan(re).size]
            if a1 < b1 then -1
            elsif a1 > b1 then 1
            else a.to_s <=> b1.to_s; end
          end
          it = ks.map{|k| @counts[k].summary}
          sexp = Sexpesque.new(:counts, *it)
          sexp
        end
      end
    end
  end
end
