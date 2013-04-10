module Hipe
  module Assess
    module Graphviz
      #
      # Hard-coded to process DM models (mebbe?), could be extended etc.
      #
      module Adapter
        include CommonInstanceMethods
        extend self
        @current = nil
        def current
          @current
        end
        def set_current_adapter name
          class_name = titleize(camelize(name))
          unless constants.include? class_name
            fail("invalid adapter \"#{name}\", expecting "<<
              oxford_comma(constants.map{|x| "\"#{underscore(x)}\""},' or ')
            )
          end
          @current = const_get(class_name)
          @current.adapter_init
          nil
        end
        module DataMapper
          include CommonInstanceMethods
          extend self
          @initted = false
          def adapter_init
            return if @initted
            t = ::DataMapper::Types
            @type = {}

            [t::Boolean, t::Serial, t::Text, ::String].
              each{|tt| @type[tt]=:ok}

            [t::Discriminator,   t::Object,
             t::ParanoidBoolean, t::ParanoidDateTime].
              each{|tt| @type[tt]=:investigate}

            @initted = true
          end
          def type property
            case @type[property.type]
            when :ok
              resp = underscore(class_basename(property.type))
            when :investigate
              fail("need a strategy for type #{property.type}")
            else
              fail("add this type to the list: #{property.type}")
            end
            resp
          end
          def association owner, name, rel
            asso = Association.new do |ass|
              ass.name = "#{owner.name} #{name}"
              ass.type = underscore(rel.class.to_s.split('::')[2]).intern
              ass.target_name = underscore(class_basename(rel.target_model))
            end
            asso
          end
        end
      end

      module GraphyNode
        include CommonInstanceMethods
        attr_accessor :entity_id
        def graphy_node_register
          GraphyNode.register(self)
        end
        @all = []
        @names = Hash.new{|h,k| h[k] = {}}
        class << self
          include CommonInstanceMethods
          attr_reader :all, :names
          def register thing
            if thing.respond_to?(:name)
              fail("don't register until you have a name") unless thing.name
              fail("name collision: #{thing.name.inspect}") if
                names[thing.class][thing.name]
            end
            thing.entity_id = all.size
            if thing.respond_to?(:name)
              names[thing.class][thing.name] = thing.entity_id
            end
            all.push thing
            nil
          end
          def tojson mixed
            case true
            when mixed.respond_to?(:tojson); mixed.tojson
            when mixed.kind_of?(Array); mixed.map{|x| tojson(x)}
            when is_scalar?(mixed); mixed
            else mixed
            end
          end
        end
        def tojson
          h = {}
          attributes.each do |(k,v)|
            h[k] = GraphyNode.tojson(v)
          end
          h
        end
      end
      class Graph < Struct.new(:models)
        include GraphyNode
        def initialize adapter_name
          Adapter.set_current_adapter adapter_name
          self.models = []
        end
        def process_model mod
          mod_ref = Model.new do |m|
            m.process_orm_model(self, mod)
          end
          models.push mod_ref
        end
      end
      class Model < Struct.new(:name, :properties, :relationships)
        include GraphyNode, CommonInstanceMethods
        def initialize
          self.properties = []
          self.relationships = []
          yield self
          graphy_node_register
        end
        def process_orm_model graph, model
          name = underscore(class_basename(model))
          self.name = name
          process_orm_relationships graph, model
          process_orm_properties model
        end
        def process_orm_properties model
          model.properties.each do |property|
            self.properties.push Property.new{|p|p.init(property)}
          end
        end
        def process_orm_relationships graph, model
          model.relationships.each do |(name, rel)|
            process_relationship graph, name, rel
          end
        end
        def process_relationship graph, name, rel
          self.relationships.push Adapter.current.association(self, name, rel)
        end
      end
      class Property < Struct.new(:name, :type)
        include GraphyNode
        def initialize
          yield self
        end
        def init property
          self.name = property.name.to_s # just to be consistent, string
          self.type = Adapter.current.type(property)
        end
      end
      class Association < Struct.new(:name, :type, :target_name)
        include GraphyNode
        def initialize
          yield self
          graphy_node_register
        end
      end
    end
  end
end

