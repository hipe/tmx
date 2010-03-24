require 'json'
require 'assess/code-adapter/orm-common/data-migration-support'

module Hipe
  module Assess
    module DataMapper
      class DrunkenMerge
        include OrmCommon::Util
        include OrmCommon::Counts

        def initialize orm
          def! :orm, orm
        end

        def merge_json ui, sin, opts
          data = JSON.parse(sin.read)
          merge_mixed_data ui, data, opts
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


      private

        def create_or_get_from_mixed(model, key, value)
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

        def create_or_get_from_scalar(model, key, value)
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
        def create_or_get_from_array(model, col_name, arr)
          list = Array.new(arr.size)
          arr.each_with_index do |mixed, idx|
            res = create_or_get_from_mixed(model, false, mixed)
            list[idx] = res
          end
          list
        end

        def create_or_get_from_hash(model, col_name, hash)
          assert_type(:hash, hash, Hash)
          local_props_strs = model.local_properties
          strange_cols = hash.keys - local_props_strs
          local_values = HashExtra[hash].slice(*local_props_strs)
          strange_values = create_or_get_strange_resultset(
            model, strange_cols, hash)
          my_resource = nil
          matching_with_local = local_values.any? ?
            model.all(local_values) : nil
          matching_with_local_ids = matching_with_local ?
            matching_with_local.map{|x| x.id} : nil
          if strange_values.any_new_resources?
            increment_created(model)
            my_resource = DmResourceExtra[model.new(local_values)]
            my_resource.add_this_strange_data(strange_values)
          else
            if strange_values.any?
              matching = resources_from_strange_hash(model, strange_values)
              if matching_with_local
                matching.reject{|x| ! matching_with_local_ids.include?(x.id) }
              end
              if ! matching.any?
                debugger; 'x'
              end
              my_resource = matching.first
            else
              debugger; 'x'
            end
          end
          if (! my_resource)
            debugger; 'x'
          end
          my_resource
        end

        def arrayify mixed
          case mixed
          when Array then mixed
          when ::DataMapper::Resource then [mixed]
          else
            fail("needed dm resource or array, had #{mixed}")
          end
        end

        # @todo ridiculous
        def resources_from_strange_hash(model, strange_hash)
          annoying_finds = {}
          model_we_want = model.name_sym
          strange_hash.each do |(col,mixed)|
            arr = arrayify(mixed)
            annoying_finds[col] = []
            arr.each do |res|
              assert_type('mixed',res,::DataMapper::Resource)
              join_name =
                [res.model.name_str, model.name_str].sort.join('_').to_sym
              join_model = orm.models[join_name]
              founds = join_model.all(res.class.name_sym => mixed)
              annoying_finds[col].concat(
                founds.map{|x| x.send(model_we_want).id}
              )
            end
          end
          ridiculous = annoying_finds.values.flatten.uniq
          resources = ridiculous.map{|id| model.get(id)}
          resources
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

        def create_or_get_strange_resultset model, cols, hash
          response = StrangeResultset.new
          cols.each do |col_name|
            strange_model, collection_name =
               model.guess_pair_for_column(col_name)
            response[collection_name] = create_or_get_from_mixed(
             strange_model, col_name, hash[col_name]
            )
          end
          response
        end
      end
    end
  end
end
