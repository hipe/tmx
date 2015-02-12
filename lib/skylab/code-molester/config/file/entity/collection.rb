module Skylab::CodeMolester

  module Config

    module File

      module Entity

        module Collection

          class << self

            def enhance target, & p

              k = Kernel__.new target

              _shell = Shell__.new(
                -> field_box_host_module do
                  k.field_box_host_module = field_box_host_module
                  nil
                end, -> do
                  k.queue_a.push :add
                  nil
                end, -> do
                  k.queue_a.push :list_as_json
                  nil
                end
              )
              _shell.instance_exec( & p )
              k.flush
            end
          end  # >>

    Shell__ = CM_.lib_.simple_shell %i( with add list_as_json )

    class Kernel__

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
                Story__.new @field_box_host_module
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
        LIB_.model_enhance @target, -> do
          services_used :configs, :config, :model
        end
      end

      private :register_for_config_services

      def list_as_json
        @target.send :include, List_as_JSON__
      end

      def add
        @target.send :include, Add__
      end
    end

  class Story__

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
      @config_section_name ||= name.map( :as_slug ).join( DASH_ )  # lossy
    end

    def inflection
      @inflection ||= CM_.lib_.entity_inflection name
    end

    def name
      @name ||= Entity_.hack_model_name_from_constant @host_mod
    end

    def natural_key_field_name
      :name  # when needed .. shell etc
    end

    def flyweight_class
      @flyweight_class ||= bld_flyweight_class
    end
  private
    def bld_flyweight_class
      if @host_mod.const_defined? FLY__, false
        @host_mod.const_get FLY__, false
      else
        @host_mod.const_set FLY__, Entity_::Flyweight.produce( self )
      end
    end
    FLY__ = :Flyweight
  end

  Collection_And_Controller__ = ::Module.new

  module Add__

    include Collection_And_Controller__

    # `add` - `event_h[:couldnt]`. please see downstreams for more:
    #   + ~Entity_Controller#`if_init_valid`
    #   + ~Config_Controller#`insert_valid_entity`

    def add field_h, opt_h, event_h
      ent = nil
      _WRAP_AGAIN = -> x { -> { x } }
      ev_p = [  # looks like [#mh-026] function chain but might be different

        -> do
          configs.if_config NILADIC_EMPTINESS_, _WRAP_AGAIN
        end,

        -> do
          entity_controller.if_init_valid field_h, opt_h,
            -> e { ent = e ; nil },
            _WRAP_AGAIN
        end,

        -> do
          nat_key = ent.natural_key
          fly = valid_entities.detect do |e|
            e.natural_key == nat_key
          end
          if fly
            -> do
              Exists_Already__[ :existing_fly, fly, :new_entity, ent ]
            end
          end
        end
      ].reduce nil do |_, p|
        p_ = p.call
        p_ and break p_
      end
      if ev_p
        _ev = ev_p.call
        event_h.fetch( :couldnt )[ _ev ]
      else
        config.insert_valid_entity ent, opt_h, event_h
      end
    end

    # (the above style is ridiculous. i have dubbed it "totem pole", but
    # it's really just a queue that we can break from. it reduced the codeside
    # and complexity (along one axis) by two thirds. at what expense remains
    # to be seen..)

    Exists_Already__ = Event_.new do |existing_fly, new_entity|
      "#{ existing_fly.inflection.lexemes.noun.singular } #{
        }already exists, won't clobber - #{ existing_fly.natural_key }"
    end
  end

  module Collection_And_Controller__

    def entity_controller
      @plugin_parent_metaservices.call_service :model,
        entity_story.name.anchored_normal
    end
  end

  List_Methods__ = ::Module.new

  module List_as_JSON__

    include List_Methods__

    def per_format_list output_line_p
      yld = ::Enumerator::Yielder.new( & output_line_p )
      _scn = to_hot_entity_scan
      _scn_ = _scn.map_by do |x|
        err = x.normalize_via_yes_or_no EMPTY_P_, IDENTITY_P_
        if err
          yld << "  /* next item may be invalid. it #{ err.message_proc[] } */"
        end
        x
      end
      scn = Callback_::Scn.articulators.eventing(
        :gets_under, _scn_,
        :always_at_the_beginning, -> y do
          y << '['
        end,
        :iff_zero_items, -> y do
          y << ' ]'
        end,
        :any_first_item, -> y, x do
          y << "#{ NEWLINE_ } #{ x }"
        end,
        :any_subsequent_items, -> y, x do
          y << ",#{ NEWLINE_ } #{ x }"
        end,
        :at_the_end_iff_nonzero_items, -> y do
          y << "#{ NEWLINE_ }]"
        end )

      while s = scn.gets
        yld << s
      end
      nil
    end
  end

  IDENTITY_P_ = -> x { x }

  module List_Methods__

    def list payload_line_p, error_p
      configs.if_config -> do
        per_format_list payload_line_p
      end, error_p
    end

    def valid_entities & p
      _scn = to_valid_entity_scan
      _scn.each( & p )
    end

    def to_valid_entity_scan
      to_hot_entity_scan.reduce_by do |entity|
        entity.normalize_via_yes_or_no NILADIC_TRUTH_, NILADIC_EMPTINESS_
      end
    end

    NILADIC_TRUTH_ = -> { true }

    def to_hot_entity_scan
      resource = event = nil
      ok = config.file.normalize_via_yes_or_no -> x do
        resource = x
        DID_
      end, -> ev do
        event = ev
        UNABLE_
      end
      if ok
        hot_entity_scan_via_resource resource
      else
        send_event event
        Callback_::Stream.the_empty_stream
      end
    end

    def hot_entity_scan_via_resource resource
      sects = resource.sections
      if sects
        hot_entity_scan_via_sections sects
      else
        Callback_::Stream.the_empty_stream
      end
    end

    def hot_entity_scan_via_sections sects
      rx = entity_story.config_section_rx
      fly = entity_story.flyweight_class.new
      _scan = sects.to_stream
      _scan.map_reduce_by do |sect|
        md = rx.match sect.item_name
        if md
          fly.set md[ 1 ], sect
          fly
        end
      end
    end

    def entity_story
      self.class.entity_story
    end
  end
        end  # collection
      end  # entity
    end  # file
  end  # config
end  # cm
