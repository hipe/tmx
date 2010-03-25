require 'json'
require 'assess/code-adapter/orm-common/data-migration-support'

module Hipe
  module Assess
    module DataMapper
      class DrunkenMerge
        include OrmCommon::Util
        include OrmCommon::Counts

        class << self
          def process_merge_json_request orm, ui, sin, opts
            new(orm).process_merge_json_request(ui, sin, opts)
            nil
          end
          private :new
        end

        def process_merge_json_request ui, sin, opts
          data = JSON.parse(sin.read)
          ::DataMapper.repository do
            merge_mixed_data ui, data, opts
          end
        end

      private

        def initialize orm
          def! :orm, orm
        end

        def merge_mixed_data ui, data, opts
          do_before_counts
          main_model = orm.abstract_model_interface.main_model
          data.each do |hash|
            res = create_or_get_from_hash(main_model, nil, hash)
            res.save if res.id.nil?
          end
          summary = do_after_counts(ui)
          ui.puts summary.jsonesque
        end

        def create_or_get_from_mixed model, key, value
          mixed_response = nil
          case my_get_type(value)
            when :scalar
              mixed_response = create_or_get_from_scalar(model, key, value)
            when :array
              mixed_response = create_or_get_from_array(model, key, value)
            when :hash
              mixed_response = create_or_get_from_hash(model, key, value)
            else; fail("no way #{my_get_type(value)}")
          end
          fail("no way, never") unless mixed_response
          mixed_response
        end

        def create_or_get_from_scalar model, key, value
          if (! model.properties.named?(key))
            fail("can't get or create from scalar without "<<
            "a column name that is a model property name: #{key}")
          end
          resource = model.first(key => value)
          if resource
            increment_retrieved(model)
          else
            increment_created(model)
            resource = model.new(key => value)
          end
          resource
        end

        # col name is ignored?
        def create_or_get_from_array model, col_name, arr
          list = Array.new(arr.size)
          arr.each_with_index do |mixed, idx|
            res = create_or_get_from_mixed(model, false, mixed)
            list[idx] = res
          end
          list
        end

        def create_or_get_from_hash model, col_name, hash
          res = nil
          assert_type(:hash, hash, Hash)
          local_props_strs = model.local_properties
          strange_cols = hash.keys - local_props_strs
          local_h = HashExtra[hash].slice(*local_props_strs)
          strange_h_query = hash.slice(*strange_cols)
          strange_h = create_or_get_strange_resultset(model, strange_h_query)
          via_local = local_h.any? ? model.all(local_h) : nil
          if strange_h.any_new_resources?
            res = new_from_local_and_strange(model, local_h, strange_h)
          elsif strange_h.any?
            via_strange = resources_from_strange_hash(model, strange_h)
            if via_local
              these = HashExtra[Hash[*(via_local.map{|x|[x.id, x]}).flatten]]
              both = via_local.map(&:id) & via_strange.map(&:id)
              found = these.slice(*both).
                map.sort{|a,b| a[0]<=>b[0]}.map{|x|x[1]}
            else
              found = via_strange.dup
            end
            if found.any?
              res = found.first # yeah i know
            else
              res = new_from_local_and_strange(model, local_h, strange_h)
            end
          else
            debugger;
            'this algorithm apparently hinges on having something strange'
            'but no problem u can just build it from local values, right?'
          end
          if (! res)
            debugger; 'x'
          end
          res
        end

        def new_from_local_and_strange model, local_h, strange_h
          # @todo almost certainly not necessary but why not
          assert_strange_is_resources_deepesque strange_h
          increment_created(model)
          res = DmResourceExtra[model.new(local_h)]
          res.add_this_strange_data(strange_h)
          res
        end

        def assert_strange_is_resources_deepesque strange_h
          no = []
          strange_h.each do |(col, mixed)|
            case mixed
            when ::DataMapper::Resource # ok
            when Array
              mixed.each_with_index do |val, idx|
                case val
                when ::DataMapper::Resource #ok
                else no.push "#{col}[#{idx}]"
                end
              end
            else
              no.push col
            end
          end
          if no.any?
            debugger
            fail("the following structpaths were neither DM resources "<<
            "nor arrays thereof:"<<oxford_comma(no))
          end
          nil
        end

        def arrayify mixed
          case mixed
          when Array then mixed
          when ::DataMapper::Resource then [mixed]
          else
            fail("needed dm resource or array, had #{mixed}")
          end
        end

        def resources_from_strange_hash model, strange_hash
          uber = map_field_names_to_relationship_shorttypes(
            model, strange_hash)
          case uber.uber_relationship
          when :all_many_to_one
            resp = strange_all_many_to_one(model, strange_hash)
          when :all_many_to_many
            resp = strange_all_many_to_many(model, strange_hash)
          when :mixed_relationship_crap
            resp = strange_mixed_relationship_crap(model, strange_hash, uber)
          else
            fail('implement this')
          end
          resp
        end

        def strange_all_many_to_one model, strange_hash
          collection = model.all(strange_hash)
          resp = collection
          resp
        end

        # @todo ridiculous
        def strange_all_many_to_many model, strange_hash
          annoying_finds = {}
          strange_hash.each do |(col,mixed)|
            annoying_finds[col] = []
            if mixed.kind_of?(Array) && 0 == mixed.size
              # special case (?) query the target table for all rows that
              # have 0 associated rows. this is bad and wrong
              join_model = orm.join_model_for(model, col)
              sql = <<-SQL
                select #{model.initials}.id
                from #{model.name_str} #{model.initials}
                left join #{join_model.name_str} #{join_model.initials}
                on #{join_model.initials}.#{model.name_str}_id =
                  #{model.initials}.id
                where #{join_model.initials}.id is null
              SQL
              ids = repository(:default).adapter.select(sql)
              annoying_finds[col].concat ids
            else
              arr = arrayify(mixed)
              arr.each do |res|
                assert_type('mixed',res,::DataMapper::Resource)
                join_model = orm.join_model_for(res.model, model)
                founds = join_model.all(res.class.name_sym => mixed)
                annoying_finds[col].concat(
                  founds.map{|x| x.send(model.name_sym).id}
                )
              end
            end
          end
          ridiculous = annoying_finds.values.flatten.uniq
          resources = ridiculous.map{|id| model.get(id)}
          resources
        end

        def strange_mixed_relationship_crap model, strange_hash, pat
          hate = pat.values - [:dm_many_to_many, :dm_many_to_one]
          fail("no: "<<oxford_comma(hate)) if hate.any?
          subhashes = Hash.new{|h,k| h[k] = Hash.new}
          pat.each do |(field, reltype)|
            subhashes[reltype][field] = strange_hash[field]
          end
          these = strange_all_many_to_many(model, subhashes[:dm_many_to_many])
          thems = strange_all_many_to_one( model, subhashes[:dm_many_to_one])
          these2 = Hash[*(these.map{|x|[x.id, x]}).flatten]
          thems2 = Hash[*(thems.map{|x|[x.id, x]}).flatten]
          common = these2.keys & thems2.keys
          wow = HashExtra[these2].slice(*common).values
        end

        module UberRelationshipForStrangeMap
          def uber_relationship
            rel_pat_uniq = values.uniq
            if rel_pat_uniq == [:dm_many_to_one]
              :all_many_to_one
            elsif rel_pat_uniq == [:dm_many_to_many]
              :all_many_to_many
            elsif rel_pat_uniq.size > 1
              :mixed_relationship_crap
            else
              debugger; 'how many damn uber relationships do you need?'
              fail('sigh')
            end
          end
        end

        def map_field_names_to_relationship_shorttypes model, strange_hash
          these = strange_hash.keys        # strings
          them = model.relationships.keys  # strings
          if (missing = these - them).any?
            fail("field names must correspond to relationship names."<<
            "don't have relationships for: "<<oxford_comma(missing))
          end
          resp = {}
          these.each do |rel_name_str|
            rel = model.relationships[rel_name_str]
            short = rel.class.shorttype
            resp[rel_name_str] = short
          end
          resp.extend UberRelationshipForStrangeMap
          resp
        end

        class StrangeResultset < Hash
          def any_new_resources?
            found_new = false
            each do |(k,mixed)|
              arr = mixed.kind_of?(Array) ? mixed : [mixed]
              arr.each do |mixed2|
                if ! mixed2.kind_of?(::DataMapper::Resource)
                  fail("huh? #{mixed2}")
                end
                if mixed2.id.nil?
                  found_new = true;
                  break 2;
                end
              end
            end
            found_new
          end
        end

        def create_or_get_strange_resultset model, strange_h
          response = StrangeResultset.new
          strange_h.each do |(col,val)|
            model2, collection_name = model.guess_pair_for_column(col)
            response[collection_name] = create_or_get_from_mixed(
              model2, col, val
            )
          end
          response
        end
      end
    end
  end
end
