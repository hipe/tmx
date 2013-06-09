module Skylab::Face

  class Namespace  # #re-open for facet 5.5

    module Facet
      def self.touch ; end  # just gets this file to load!
    end

    class << self
    private

      undef_method :namespace
      def namespace norm_i, *a, &b
        @story.namespace norm_i, *a, &b
      end
    end

    Mechanics__ = NS_Mechanics_
  end

  class NS_Sheet_  # #re-open for facet 5.5

    # (the way it works out this is nicer structured as a top-down narrative
    # rather than being broken into the traditional sections, hence you will
    # see private/protected called explicitly after each relevant method.)

    def namespace norm_i, *a, &b
      if ! @skip_h[ norm_i ]
        write_ns norm_i, -> ns do
          # if one existed by name `norm_i` already, is `ns`
          ns.absorb_additional_namespace_definition a, b
          nil
        end, -> do  # else a namespace does not yet exist as `norm_i`
          build_child_namespace_sheet norm_i, a, b
        end
      end
      nil  # our internal struct is internal
    end

    def write_ns norm_i, yes, no  # internally used to create or update n.s
      @node_open and raise "can't add namespace #{
        }when command is still open - #{ norm_i }"
      @box.if? norm_i, -> nss do
        nss.class.metastory.is_leaf and raise "attempt to reopen a command #{
          }as a namespace - #{ norm_i }"
        yes[ nss ]
        nss.do_skip and raise "cannot skip an already opened namespace."
        nil
      end, -> do
        nss = no[] or raise "expecting `no` block to produce namespace"
        if nss.do_include
          @surface_mod[].story._scooper.add_name_at_this_point norm_i
          @box.add norm_i, nss
        else
          @skip_h[ norm_i ] = true
        end
        nil
      end
      nil  # our internal struct is internal
    end
    private :write_ns

    # `build_child_namespace_sheet`

    -> do  # (funtions are bottom-up, methods top-down)

      mlf = -> { "module-loading function" } ; db = -> { "definition block" }
      nsm = -> { "namespace module" }
      mutex = -> mf, b do
        ( mf && b and i = 2 ) or ( ! ( mf || b ) and i = 0 )
        i and raise ::ArgumentError, "must have exactly 1 (#{ mlf[] }#{
          } OR #{ db[] }) - had #{ i }"
      end
      box_mod = -> sm do
        if sm.const_defined? :Commands, false
          sm.const_get :Commands, false else
          sm.const_set :Commands, ::Module.new
        end
      end
      parse_args = -> a do
        a.length.nonzero? && a[ 0 ].respond_to?( :call ) and mf = a.shift
        if a.length.nonzero?
          if 1 == a.length and a[ 0 ].respond_to? :each_pair
            xtra_pairs = a.shift
          else
            xtra_pairs = Services::Basic::Hash::Pair_Enumerator.new a
          end
        end
        [ mf, xtra_pairs ]
      end
      define_method :build_child_namespace_sheet do |norm_i, a, b|
        nf = Services::Headless::Name::Function.new norm_i
        mf, xtra_pairs = parse_args[ a ]
        mutex[ mf, b ]
        if mf
          self.class.new( nil ).init_with_module_function mf, nf, xtra_pairs
        else
          build_into b, nf, xtra_pairs
        end
      end
      private :build_child_namespace_sheet

      def has_name
        @name
      end

      def name  # public like parent
        if @name then @name else
          fail "who is asking for namefunc of #{ @surface_mod[] }?"
        end
      end

      define_method :absorb_additional_namespace_definition do |a, b|
        mf, xtra_pairs = parse_args[ a ]
        mf || b and mutex[ mf, b ]
        xtra_pairs and absorb_xtra xtra_pairs
        if mf
          @surface_mod_origin_i and raise "can't set a #{ mlf[] } to a #{
            }#{ nsm[] } already originates with #{ @surface_mod_origin_i }"
          @surface_mod_origin_i = :function
          @surface_mod = mf
        elsif b
          if @surface_mod_origin_i
            :blocks == @surface_mod_origin_i or raise "can't add a #{ db[] }#{
              } to a #{ nsm[] } that originates via #{ @surface_mod_origin_i }"
            @block_a << b
          else
            @surface_mod_origin_i = :blocks
            @block_a = [ b ]
          end
        end
      end
      protected :absorb_additional_namespace_definition

      define_method :build_into do |block, name_func, xtra_pairs|
        bm = box_mod[ @surface_mod[] ]
        co = name_func.as_const
        bm.const_defined?( co, false ) and raise "sanity - don't do this"
        sty = ( bm.const_set co, ::Class.new( Namespace ) ).story
        sty.init_with_block block, name_func, xtra_pairs
      end
      private :build_into

    end.call

    def init_with_normalized_local_name i  # for hacks, exploration
      @name and fail "won't clobber existing name"
      @name = Services::Headless::Name::Function.new i
      self
    end

    def init_with_module_function mf, nf, xtra_pairs
      @surface_mod = mf
      init_extended_ns_sheet :function, nf, xtra_pairs
    end
    protected :init_with_module_function

    def init_with_block b, nf, xtra_pairs
      @block_a = [ b ]
      init_extended_ns_sheet :blocks, nf, xtra_pairs  # overwrites `:module`, ok.
    end
    protected :init_with_block

    def init_extended_ns_sheet i, nf, xtra_pairs
      @hot = nil
      @surface_mod_origin_i = i
      @name = nf
      xtra_pairs and absorb_xtra xtra_pairs
      self
    end
    private :init_extended_ns_sheet


    -> do

      # `hot_h` - when your namespace is expressed with <key>, call <value>
      # to resolve a "hot" function (a function for building hot clients).

      hot_h = {
        module: -> _ do
          -> psvcs, *r_to_cmd do
            sm = @surface_mod[]
            x = sm.new self, psvcs, * r_to_cmd
            if sm.metastory.is_leaf then x else
              x.instance_variable_get :@mechanics  # #eew but [#037]
            end
          end
        end,
        function: -> _ do
          strange_mod = @surface_mod[]
          if strange_mod
            strange_mod::Adapter::For::Face::Of::Hot[ self, strange_mod ]
          end
        end,
        blocks: -> parent_svcs do
          if @block_a.length.nonzero?
            sm = @surface_mod[]
            @block_a.length.times do |idx|
              b = @block_a[ idx ] ; @block_a[ idx ] = nil
              sm.class_exec( & b )  # MONEY MONEY MONEY MONEY
            end
            @block_a.compact!
          end
          instance_exec parent_svcs, & hot_h.fetch( :module )
        end
      }

      define_method :hot do |psvcs, *rest_to_cmd|  # `psvcs` = parent services
        if @hot.nil?
          @hot = instance_exec psvcs, & hot_h.fetch( @surface_mod_origin_i )
        end
        if @hot
          svcs = @hot.call psvcs, *rest_to_cmd
          svcs.pre_execute  # placement here is sketchy
          svcs
        end
      end
    end.call
  end

  class NS_Mechanics_  # #re-open for facet 5.5

    -> do  # `self.enhance` - see subclass version

      a_len = {
        2 => -> sheet, parent_services do
          { sheet: sheet, parent_services: parent_services }  # eew / meh
        end,
        3 => -> sheet, parent_services, slug do
          { sheet: sheet, parent_services: parent_services, slug: slug }
        end
      }

      define_singleton_method :enhance do |surface, a|
        h = a_len.fetch( a.length ) do |k|
          raise ::KeyError, "bad number of args to build a namespace #{
            }(#{ k }), expecting #{ a_len.keys * ' or ' }"
        end.call( * a )
        _enhance surface, h
      end
    end.call

    def self.__enhance surface, sheet, parent_services, slug
      new sheet, surface, parent_services, slug
    end
  end

  # ~ 5.2.1 - skip ~

  class NS_Sheet_  # #re-open
    def do_include
      ! do_skip
    end
    attr_reader :do_skip
  private
    def absorb_xtra_skip x
      @do_skip = x
      nil
    end
  end

  # ~ 5.2.2 - desc ~

  class NS_Sheet_
  private
    def absorb_xtra_desc x
      ( @desc_proc_a ||= [ ] ) << x
      nil
    end
  end

  # ~ 5.2.3 - assorted mutabilities ~

  class NS_Sheet_

    def add_namespace_sheet oro  # #called-by revelation, fun hacks
      write_ns oro.name.local_normal, -> ns do  # not slug, like method
        raise "sanity - will not attempt to merge a new namespace #{
          }sheet into an existing node."
      end, -> do
        oro
      end
    end
  end
end
