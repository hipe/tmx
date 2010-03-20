module Hipe
  module Assess
    module DataMapper

      module DmResourceExtra
        include CommonInstanceMethods
        def self.[] obj
          obj.extend self unless obj.kind_of? self
        end
        def add_this_strange_data strange
          strange.each do |(k,mixed)|
            if mixed.kind_of?(::DataMapper::Resource)
              add_this_strange_resource(mixed)
            elsif mixed.kind_of?(Array)
              add_this_strange_array(mixed)
            else
              fail("this data is too strange: #{mixed}")
            end
          end
          nil
        end

        def add_this_strange_resource mixed
          assert_type('mixed', mixed, ::DataMapper::Resource)
          name_sym = mixed.class.name_sym
          coll = self.send(name_sym)
          coll.push(mixed)
          nil
        end

        def add_this_strange_array(array)
          array.each do |mixed|
            add_this_strange_resource(mixed)
          end
        end

      end

      module DmModelExtra
        include CommonInstanceMethods

        #
        # The enhancements created here are for ad-hoc needs of
        # the orm-manager when doing data-merges and schema migrations,
        # etc.  The should not be part of the business logic for the
        # final application.
        #
        # This module should only be referred to in one place.
        #

        def self.[] obj
          obj.extend self unless obj.kind_of? self
          obj.init_dm_model_class_enhancement
          obj
        end

        def name_sym
          name_str.to_sym
        end

        def name_str
          underscore(class_basename(self))
        end

        def relationship_token_map
          @relationship_token_map ||= build_relationship_token_map
        end

        def local_properties
          @local_properties ||= properties.map(&:name).map(&:to_s)
        end

        # @return [model, collection_name]
        def guess_pair_for_column col_name
          @pair_guesses_for_column[col_name] ||= begin
            names = guess_relevant_relationship_names(col_name)
            fail("need more logic if names > 2") if names.size > 2
            fail("what happened? no relevant names found")  if names.size == 0
            fail("probably ok but check this") if names.size == 1
            foreign_table_name = names.first # hackerdom
            foreign = foreign_model_for_relationship(names[0])
            [foreign, foreign_table_name]
          end
        end

        # private to this module
        def init_dm_model_class_enhancement
          @pair_guesses_for_column = {}
        end

      private

        def guess_relevant_relationship_names col_name
          toks = col_name.split('_')
          sets = relationship_token_map.values_at(*toks)
          names = sets.map(&:to_a).flatten.uniq.sort{|a,b| a.size<=>b.size}
          names
        end

        def foreign_model_for_relationship relationship
          m2m = relationships[relationship]
          unless m2m.kind_of?(
            ::DataMapper::Associations::ManyToMany::Relationship
          )
            debugger; 'straight forward but work it out'
          end
          foreign =  m2m.via.parent_model
          foreign
        end

        #
        # this might be a dumb way to do it, we are trying to handle
        # cases of fields in the source file that have underscores
        #
        def build_relationship_token_map
          rel_map = HashExtra[Hash.new{|h,k| h[k] = Set.new}]
          my_name = name_sym.to_s # no leading module names
          relationships.each do |(rel_name,)|
            toks = (rel_name.split('_') - [my_name])
            toks.each{|tok| rel_map[tok].add(rel_name)}
          end
          rel_map
        end
      end
    end
  end
end
