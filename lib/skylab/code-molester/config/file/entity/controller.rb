module Skylab::CodeMolester::Config::File::Entity

  module Entity::Controller

    def self.enhance controller_class, & def_blk

      stct = Conduit_::struct.new
      Conduit_.new( -> w { stct[ :with ] = w },
                    ->   { stct[ :add  ] = true }

      ).instance_exec( & def_blk )
      flsh = Flusher_.new( controller_class, * stct.to_a )
      flsh.flush

    end

    Conduit_ = MetaHell::Enhance::Conduit.new %i| with add |

    class Flusher_
      def initialize controller_class, fld_box_host_mod, do_add
        @target = controller_class
        @queue_a = [ ]
        @field_mod = fld_box_host_mod and @queue_a << :fields
        @queue_a << :module_accessors if !
          controller_class.method_defined? :entity_anchor_module
        @queue_a << :register_for_config_services
        @queue_a << :add if do_add
        nil
      end

      def flush
        while i = @queue_a.shift ; send i ; end
        nil
      end

    private

      def fields
        Basic::Field::Reflection.enhance( @target ).with @field_mod
      end

      def module_accessors
        Face::Services::ModuleAccessors.enhance @target do
          private_methods do
            module_reader :collection_module, '../Collection'
          end
        end
        nil
      end

      def register_for_config_services
        Face::Model.enhance( @target ).services %i|

          configs
          config
        |
      end

      def add
        @target.send :include, Entity::Controller::Add_
      end
      private :add
    end
  end

  module Entity::Controller::Common_
  end

  module Entity::Controller::Add_

    include Entity::Controller::Common_

    def if_init_valid field_h, opt_h, if_yes, if_no
      ok = e = nil
      @field_h = field_h ; @opt_h = opt_h
      begin
        e = extra_fields and break
        e = missing_fields and break
        e = normalize_fields and break
        ok = self
      end while nil
      e ? if_no[ e ] : if_yes[ ok ]
    end

  private

    def extra_fields
      xtra_a = @field_h.keys - field_box._order
      if xtra_a.length.nonzero?
        Extra_[ xtra_a: xtra_a ]
      end
    end

    join = -> a do
      a.map { |x| "\"#{ x }\"" } * ', '
    end

    Extra_ = Entity::Event.new do |xtra_a|
      "unexpected field(s) - #{ join[ xtra_a ] }"
    end

    def missing_fields
      miss_a = required_fields.reduce [] do |m, fld|
        k = fld.normalized_name
        if fld.is_required and ! @field_h.key?( k ) ||
              @field_h[ k ].nil? # might become option one day.
          m << fld
        end
        m
      end
      if miss_a.length.nonzero?
        Missing_[ miss_o_a: miss_a ]
      end
    end

    Missing_ = Entity::Event.new do |miss_o_a|
      "missing required field(s) - #{ join[ miss_o_a.map(& :normalized_name )]}"
    end

    def normalize_fields
      did = nil
      @box ||= ( did = true ) && MetaHell::Formal::Box::Open.new
      did or fail "sanity"
      @nerk_a = nil
      a = Entity::Event::Aggregation.new
      @field_h.each do |k, v|
        a << ( pound field_box[ k ], v )
      end
      a.flush
    end

    def pound fld, v
      a = nil
      add = -> x { ( a ||= [ ] ) << x }
      if fld.fields.has? :regex and fld.has_regex
        add[ pound_regexp fld ]
      end
      if ! v.nil?
        # note we might be adding invalid fields!
        @box.add fld.normalized_name, v
        @field_h.delete fld.normalized_name
      end
      if a
        flush_pound a, fld, v
      end
    end

    def flush_pound a, fld, v
      error_a = nil
      pound = -> x, ctx do
        err_a = nil
        err = -> msg do
          ( err_a ||= [ ] ) << msg
        end
        a.each do |pnd|
          pnd[ x, err ]
        end
        if err_a
          error_a ||= [ ]
          if ctx
            error_a.concat err_a.map { |xx| "#{ ctx[] }#{ xx }" }
          else
            error_a.concat err_a
          end
          err_a = nil
        end
      end
      is_list = if ! fld.fields.has? :list then false else
        fld.is_list
      end
      if is_list
        if v
          v.each_with_index do |x, idx|
            pound[ x, -> { "[#{ idx }] " } ]
          end
        end
      else
        pound[ v, -> { ' ' } ]  # eek  - allow "foo[0] did .." vs "foo did"
      end
      if error_a
        Invalid_[ pred_a: error_a, field: fld ]
      end
    end

    Invalid_ = Entity::Event.new do |pred_a, field|
      o = ''
      lbl = field.normalized_name.id2name  # #todo
      Basic::List::Evented::Articulation pred_a do
        always_at_the_beginning      ->     { o << "#{ lbl }" }
        iff_zero_items               ->     { o << "was fine." }
        any_first_line               ->   s { o << "#{ s }." }
        any_subsequent_lines         ->   s { o << "#{ lbl }#{ s }." }
      end
      o
    end

    def pound_regexp fld  # assume `regex`
      -> x, err do
        if fld.get_regex !~ x
          if fld.fields.has? :rx_fail_predicate_tmpl and
                      fld.has_rx_fail_predicate_tmpl
            err[ render_template fld.get_rx_fail_predicate_tmpl, fld, x ]
          else
            err[ "was invalid" ]
          end
        end
        nil
      end
    end
  end

  module Entity::Controller::Common_


    def render_template tmpl_str, fld, x
      h = {
        ick: -> { "\"#{ x }\"" }
      }
      tmpl_str.gsub( Headless::CONSTANTS::MUSTACHE_RX ) do
        h.fetch( $~[1].intern ).call
      end
    end
    private :render_template

    def config_file_section_name
      entity_story.config_section_name
    end

    def entity_story
      @entity_story ||= collection_module.entity_story
    end

    def natural_key
      @box.fetch entity_story.natural_key_field_name
    end

    def body_field_pairs
      ::Enumerator.new do |y|
        body_fields.each do |bf|
          k = bf.normalized_name
          @box.if? k, -> v do  # it won't have optional fields sometimes
            if ! v.nil?
              y.yield k, v
            end
          end, -> { }
        end
        nil
      end
    end
  end
end
