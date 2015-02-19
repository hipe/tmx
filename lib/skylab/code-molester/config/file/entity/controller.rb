module Skylab::CodeMolester

  module Config

    module File

      module Entity

        module Controller

    def self.enhance controller_class, & def_blk

      stct = Shell__::struct.new
      Shell__.new( -> w { stct[ :with ] = w },
                    ->   { stct[ :add  ] = true }

      ).instance_exec( & def_blk )
      flsh = Kernel__.new( controller_class, * stct.to_a )
      flsh.flush

    end

    Shell__ = LIB_.simple_shell %i( with add )

    class Kernel__

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
        LIB_.field_reflection_enhance( @target ).with @field_mod
      end

      def module_accessors
        LIB_.module_accessors.enhance @target do
          private_methods do
            module_reader :collection_module, '../Collection'
          end
        end
        nil
      end

      def register_for_config_services
        LIB_.model_enhance @target, -> do
          services_used :configs, :config
        end
      end

      def add
        @target.include Add__
      end
    end

    module Common__
      include Entity_::Model::InstanceMethods
    end

  module Add__

    include Common__

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


            def rendered_surface_pairs
              skip_me = entity_story.natural_key_field_name
              upstream = @string_box.to_pair_stream
              y = []
              Callback_.stream do
                begin
                  pair = upstream.gets
                  pair or break
                  i = pair.name_symbol
                  skip_me == i and redo
                  fld = field_box.fetch i
                  upstream_x = pair.value_x
                  if fld.is_list and upstream_x.respond_to? :each
                    upstream_x.each do |s|
                      marshal y, s, fld
                    end
                  else
                    marshal y, upstream_x, fld
                  end
                  if y.length.zero?
                    redo
                  end
                  pair.value_x = y * ', '  # yeah sure why not, b/c we can
                  y.clear
                end while false
                pair  # just for fun we result in the pair but ..
              end.flush_to_immutable_with_random_access_keyed_to_method :name_symbol,
                :each_pair_mapper, -> pair do
                  [ pair.name_symbol, pair.value_x.value_x ]  # .. then we have 2 pairs
                end
            end

          private

            def marshal y, x, fld
              _s = if ESCAPE_ME_CHARACTER_RX__ =~ x
                "\"#{
                   x.gsub ESCAPE_ME_CHARACTER_RX__ do
                     "\\#{ $~[ 0 ] }"
                   end
                }\""
              else
                x
              end
              y << _s ; nil
            end
            ESCAPE_ME_CHARACTER_RX__ = /[\"]/


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
        Extra__[ :xtra_h, xtra_h ]
      end
    end

    LIB_.hash_lib.pairs_at :repack_difference, & method( :define_method )

    join = -> a do
      a.map { |x| "\"#{ x }\"" } * ', '
    end

    Extra__ = Event_.new do |xtra_h|
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
        Missing__[ :miss_o_a, miss_a ]
      end
    end

    Missing__ = Event_.new do |miss_o_a|
      "missing required field(s) - #{ join[ miss_o_a.map(& :local_normal_name )]}"
    end

    def normalize_fields
      did = nil
      @string_box ||= ( did = true ) && Callback_::Box.new
      did or fail "sanity"
      @nerk_a = nil
      a = Event_::Aggregation.new
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
        Invalid__[ :predicate_s_a, error_a, :field, fld ]
      end
    end

    Invalid__ = Event_.new do |predicate_s_a, field|

      lbl = field.local_normal_name.id2name  # #todo

      _upstream_scan = Callback_::Stream.via_nonsparse_array predicate_s_a

      scn = Callback_::Scn.articulators.eventing(

        :gets_under, _upstream_scan,

        :always_at_the_beginning, -> y do
          y << "#{ lbl }"
        end,

        :iff_zero_items, -> y do
          y << " was fine."
        end,

        :any_first_item, -> y, s do
          y << "#{ s }."
        end,

        :any_subsequent_items, -> y, s do
          y << "#{ lbl }#{ s }."
        end )

      s_a = []
      while s = scn.gets
        s_a.push s
      end
      s_a * SPACE_
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

  module Common__

    private def render_template tmpl_str, fld, x

      h = {
        ick: -> { "\"#{ x }\"" }
      }

      tmpl_str.gsub LIB_.string_lib.mustache_regexp do
        h.fetch( $~[1].intern ).call
      end
    end

    def config_file_section_name
      entity_story.config_section_name
    end

    def entity_story
      @entity_story ||= collection_module.entity_story
    end

    def natural_key
      @string_box.fetch entity_story.natural_key_field_name
    end
  end  #+8end
        end
      end
    end
  end
end
