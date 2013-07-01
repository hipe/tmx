module Skylab::CodeMolester::Config::File::Entity

  module Entity::Collection

    def self.enhance target, & def_blk

      fls = Flusher_.new target

      Conduit_.new(
        -> field_box_host_module do
          fls.field_box_host_module = field_box_host_module
          nil
        end, -> do
          fls.queue_a << :add
          nil
        end, -> do
          fls.queue_a << :list_as_json
          nil
        end
      ).instance_exec( & def_blk )
      fls.flush
    end

    Conduit_ = MetaHell::Enhance::Conduit.new %i|
      with
      add
      list_as_json
    |

    class Flusher_

      def initialize coll_kls
        @target = coll_kls
        @queue_a = [ ]
        @field_box_host_module = nil
      end

      attr_writer :field_box_host_module

      attr_reader :queue_a

      def flush
        @field_box_host_module or raise "use `with` in your DSL clause to #{
          }indicate a field box host module (a module with `field_box`)."
        @story = if @target.const_defined? :ENTITY_STORY_, false
                         @target.const_get :ENTITY_STORY_, false
                 else    @target.const_set :ENTITY_STORY_, (
                Story_.new @field_box_host_module
              )
                 end
        sty = @story
        @target.define_singleton_method :entity_story do sty end
        register_for_config_services
        @queue_a.each do |i|
          send i
        end
        nil
      end

      def register_for_config_services
        Face::Model.enhance @target do
          services_used :configs, :config, :model
        end
      end

      private :register_for_config_services

      def list_as_json
        @target.send :include, Entity::Collection::List::As_JSON
      end

      def add
        @target.send :include, Entity::Collection::Add_
      end
    end
  end

  class Entity::Collection::Story_

    def initialize host_mod
      @host_mod = host_mod
    end

    def host_module
      @host_mod
    end

    def config_section_rx
      @config_section_rx ||=
        /\A#{ ::Regexp.escape config_section_name }[ ]"([^"]+)"\z/
    end

    def config_section_name
      @config_section_name ||= name.map( :as_slug ).join( '-' )  # lossy
    end

    def inflection
      @inflection ||= Headless::Entity::Inflection.new name
    end

    def name
      @name ||= Entity::FUN.hack_model_name_from_constant[ @host_mod ]
    end

    def natural_key_field_name
      :name  # when needed .. conduit etc
    end

    def flyweight_class
      @flyweight_class ||= begin
        if @host_mod.const_defined?( :Flyweight, false ) or
            @host_mod.const_probably_loadable? :Flyweight
          @host_mod.const_get :Flyweight, false
        else  # meh, it makes logic easier
          @host_mod.const_set :Flyweight,
            Entity::Flyweight.produce( self )
        end
      end
    end
  end

  module Entity::Collection::Collection_And_Controller_
  end

  module Entity::Collection::Add_

    include Entity::Collection::Collection_And_Controller_

    # `add` - `event_h[:couldnt]`. please see downstreams for more:
    #   + ~Entity_Controller#`if_init_valid`
    #   + ~Config_Controller#`insert_valid_entity`

    def add field_h, opt_h, event_h
      ent = nil ; alt = [
        -> { configs.if_config -> { }, -> err { -> { err } } },
        -> {
          entity_controller.if_init_valid field_h, opt_h,
            -> e { ent = e ; nil },
            -> err { -> { err } } },
        -> {
          fly = valid_entities.detect do |e|
            e.natural_key == ent.natural_key
          end and -> do
            Exists_::Already_[ existing_fly: fly, new_entity: ent ]
          end }
      ].reduce nil do |_, f|
        x = f.call and break x
      end
      if alt
        event_h.fetch( :couldnt ).call alt.call
      else
        config.insert_valid_entity ent, opt_h, event_h
      end
    end

    # (the above style is ridiculous. i have dubbed it "totem pole", but
    # it's really just a queue that we can break from. it reduced the codeside
    # and complexity (along one axis) by two thirds. at what expense remains
    # to be seen..)

    module Exists_
    end

    Exists_::Already_ = Entity::Event.new do |existing_fly, new_entity|
      "#{ existing_fly.inflection.lexemes.noun.singular } #{
        }already exists, won't clobber - #{ existing_fly.natural_key }"
    end
  end

  module Entity::Collection::Collection_And_Controller_

    def entity_controller
      @plugin_parent_metaservices.call_service :model,
        entity_story.name.anchored_normal
    end
  end

  module Entity::Collection::List
  end

  module Entity::Collection::List::Methods

  end

  module Entity::Collection::List::As_JSON

    include Entity::Collection::List::Methods

    def _list yf
      yes = comma = ','
      no = nil
      enum = ::Enumerator.new do |y|
        lines = lines_using -> e { e.jsonesque }
        lines.each do |error_line, mixed_line|
          if error_line
            y << error_line
            comma = no
          end
          if mixed_line
            y << mixed_line
            comma = yes
          end
        end
      end

      o = Headless::IO::Interceptors::Chunker::F.new yf

      Basic::List::Evented::Articulation enum do
        always_at_the_beginning      ->     { o << '[' }
        iff_zero_items               ->     { o << ' ]' }
        any_first_item               ->   s { o << "\n  #{ s }" }
        any_subsequent_items         ->   s { o << "#{ comma }\n  #{ s }" }
        at_the_end_iff_nonzero_items ->     { o << "\n]" }
      end
      o.flush
      nil
    end
  end

  module Entity::Collection::List::Methods

    def list payload_line, error_event
      configs.if_config -> do
        _list payload_line
      end, error_event
    end

    def lines_using render
      ::Enumerator.new do |y|
        hot_entities.each do |e|
          e.if_valid -> do
            y.yield nil, "  #{ render[ e ] }"
          end, -> invalid_o do
            y.yield "  /* next item may be invalid. it #{
              invalid_o.message_proc[] } */", "  #{ render[ e ] }"
          end
        end
      end
    end

    def valid_entities
      ::Enumerator.new do |y|
        hot_entities.each do |e|
          e.if_valid -> do
            y << e
          end
        end
      end
    end

    def hot_entities
      ::Enumerator.new do |y|
        config.file.if_valid( -> f do
          hot_entities_in_resource y, f
        end, -> invalid_reason_obj do
          # important - when file was invalid, this is the hacky way we
          invalid_reason_obj  # can get more info.
        end )
      end
    end

    def hot_entities_in_resource y, resource
      rx = entity_story.config_section_rx  # or change to i.m maybe..
      entity_story.flyweight_class.with_instance do |fly|
        sects = resource.sections
        if sects
          sects.each do |sect|
            if rx =~ sect.item_name
              fly.set $~[1], sect
              y << fly
            end
          end
        end
      end
      # important - result of `each` must be nil iff resource was valid
      nil
    end

    def entity_story
      self.class.entity_story
    end
  end
end
