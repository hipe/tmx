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
        MetaHell::Module::Accessors.enhance @target do
          private_methods do
            module_reader :collection_module, '../Collection'
          end
        end
        nil
      end

      def register_for_config_services
        Face::Model.enhance @target do
          services_used :configs, :config
        end
      end

      def add
        @target.send :include, Entity::Controller::Add_
      end
      private :add
    end
  end

  module Entity::Controller::Common_
    include Entity::Model::InstanceMethods
  end

  module Entity::Controller::Add_

    include Entity::Controller::Common_

    def if_init_valid field_h, opt_h, if_yes, if_no
      ok = e = nil
      @field_h = field_h ; @opt_h = opt_h
      begin
        e = normalize_field_keys and break
        e = missing_fields and break
        e = normalize_fields and break
        ok = self
      end while nil
      e ? if_no[ e ] : if_yes[ ok ]
    end

    # `rendered_config_pairs` - this is what gets actually written to the
    # file. the value part of the tuple should be the raw string to be
    # written after the equals sign -- no further escaping will be
    # performed.

    -> do
      a = [ ]
      define_method :rendered_config_pairs do
        ::Enumerator.new do |y|
          skip_me = entity_story.natural_key_field_name
          @string_box.each do |nn, str|
            skip_me == nn and next
            fld = field_box.fetch nn
            if fld.is_list and str.respond_to? :each
              str.each do |s|
                _get_escape_string_token a, fld, s
              end
            else
              _get_escape_string_token a, fld, str
            end
            if a.length.nonzero?
              y.yield nn, "#{ a * ', ' }"
              a.clear
            end
          end
          nil
        end
      end
    end.call

  private

    -> do
      rx = /[\"]/
      define_method :_get_escape_string_token do |a, fld, str|
        ::String === str or fail "sanity - don't use normalized values here -#{
          } #{ str.class }"
        outstr = if rx =~ str
          "\"#{ str.gsub( rx ) { "\\#{ $~[ 0 ] }" } }\""
        else
          str  # even with e.g spaces!
        end
        a << outstr
        nil
      end
    end.call

    # `normalize_field_keys`

    def normalize_field_keys
      once_h = ::Hash[ field_box.map do |fld|
        [ ( fld.has_ivar ? fld.ivar_value : fld.local_normal_name ), fld ]
      end ]
      xtra_h = nil
      @field_h.keys.each do |k|
        if ! once_h.key? k
          ( xtra_h ||= { } )[ k ] = @field_h[ k ]
          next
        end
        fld = once_h.fetch k
        if fld.has_ivar
          @field_h[ fld.local_normal_name ] = @field_h.delete k  # eek NOTE
          k = fld.local_normal_name
        end
      end
      if xtra_h
        Extra_[ xtra_h: xtra_h ]
      end
    end

    Basic::Hash::FUN.pairs_at :repack_difference  do |i, p|
      define_method i, p
    end

    join = -> a do
      a.map { |x| "\"#{ x }\"" } * ', '
    end

    Extra_ = Entity::Event.new do |xtra_h|
      "unexpected field(s) - #{ join[ xtra_h.keys ] }"
    end

    def missing_fields
      miss_a = required_fields.reduce [] do |m, fld|
        k = fld.local_normal_name
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
      "missing required field(s) - #{ join[ miss_o_a.map(& :local_normal_name )]}"
    end

    def normalize_fields
      did = nil
      @string_box ||= ( did = true ) && MetaHell::Formal::Box::Open.new
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
        @string_box.add fld.local_normal_name, v
        @field_h.delete fld.local_normal_name
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
      lbl = field.local_normal_name.id2name  # #todo
      Basic::List::Evented::Articulation pred_a do
        always_at_the_beginning      ->     { o << "#{ lbl }" }
        iff_zero_items               ->     { o << "was fine." }
        any_first_item               ->   s { o << "#{ s }." }
        any_subsequent_items         ->   s { o << "#{ lbl }#{ s }." }
      end
      o
    end

    def pound_regexp fld  # assume `regex`
      -> x, err do
        if fld.regex_value !~ x
          if fld.fields.has? :rx_fail_predicate_tmpl and
                      fld.has_rx_fail_predicate_tmpl
            err[ render_template fld.rx_fail_predicate_tmpl_value, fld, x ]
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
      tmpl_str.gsub Basic::String::MUSTACHE_RX do
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
      @string_box.fetch entity_story.natural_key_field_name
    end
  end
end
