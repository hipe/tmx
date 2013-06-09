module Hipe
  module Assess
    module DataMapper
      module DmAssociationExtra
        include CommonInstanceMethods
        extend self
        @hacked = false
        def hacked?; @hacked end
        def hack!
          return if hacked?
          # creates shorrtype() => :dm_many_to_one, :dm_many_to_many
          %w(ManyToOne ManyToMany).map do |n|
            ::DataMapper::Associations.const_get(n)
          end.each do |ass|
            rel = ass.const_get('Relationship')
            unless rel.respond_to?(:shorttype)
              type = ('dm_'+underscore(class_basename(ass))).to_sym
              class<<rel; self end.send(:define_method,:shorttype){type}
            end
          end
          @hacked = true
        end
      end

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

        # depending on the relationship we are either adding to
        # collection or non-destructively setting it
        #
        def add_this_strange_resource mixed
          assert_type('mixed', mixed, ::DataMapper::Resource)
          name_sym = mixed.class.name_sym
          rel = relationships[name_sym]
          case rel.class.shorttype
          when :dm_many_to_one
            unless self.send(name_sym).nil?
              fail("won't set property when it already exists: #{name_sym}")
            end
            self.send("#{name_sym}=", mixed)
          when :dm_many_to_many
            collec = self.send(name_sym)
            collec.push(mixed)
          end
          nil
        end

        def add_this_strange_array(array)
          array.each do |mixed|
            add_this_strange_resource(mixed)
          end
        end

      end

      module DmModelExtra
        #
        # The enhancements created here are for ad-hoc needs of
        # the orm-manager when doing data-merges and schema migrations,
        # etc.  The should not be part of the business logic for the
        # final application.
        #
        # This module should only be referred to in one place.
        #
        include CommonInstanceMethods
        @initials_to_model = {}
        @model_to_initials = {}
        class << self
          def [] obj
            obj.extend self unless obj.kind_of? self
            obj.init_dm_model_class_enhancement
            obj
          end
          attr_accessor :initials_to_model, :model_to_initials

        end

        def initials
          @initials ||= begin
            attempt_base = class_basename(self).scan(/[A-Z]/).join.downcase
            attempt = attempt_base
            incr = 2
            while thing = DmModelExtra.initials_to_model[attempt]
              fail('huh?') if thing == self
              attempt = "#{attempt}#{incr}"
              incr += 1
            end
            DmModelExtra.initials_to_model[attempt] = self
            DmModelExtra.model_to_initials[self] = attempt
            attempt
          end
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
            case names.size
            when 0
              fail("what happened? no relevant names found")
            when 1
              foreign_table_name = names.first
            when 2
              foreign_table_name = names.first # hackerdom
            else
              fail("need more logic if names > 2")
            end
            foreign = foreign_model_for_relationship(foreign_table_name)
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
          rel = relationships[relationship]
          case rel.class.shorttype
          when :dm_many_to_many
            foreign = rel.via.parent_model
          when :dm_many_to_one
            foreign = rel.target_model
          else
            fail 'do me' # what is this strange new relationship?
          end
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
