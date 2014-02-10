class Skylab::Face::CLI

  # ~ facet 5.3x - recursively nested namespaces and ns properties ~

  CLI.const_get :Set, false

  class Namespace  # #re-open for 5.3x

    module Facet
      def self.touch ; nil end    #kick-the-loading-warninglessly-and-trackably
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

  class NS_Sheet_  # #re-open for 5.3x

    def namespace norm_i, *a, &p
      @skip_h[ norm_i ] or do_ns norm_i, a, p
    end
  private
    def do_ns norm_i, a, p
      write_ns norm_i, -> ns do
        ns.absrb_additional_namespace_definition a, p  # #jump-1
      end, -> do  # else a namespace does not yet exist as `norm_i`
        bld_child_namespace_sheet norm_i, a, p  # #jump-2
      end ; nil
    end

    def write_ns norm_i, yes_p, no_p  # internally used to create or update n.s
      @node_open and raise say_cant_add_namespace_to_open_command norm_i
      @box.if? norm_i, -> nss do
        updt_namespace norm_i, nss, yes_p
      end, -> _bx do
        add_ns norm_i, no_p
      end ; nil  # our internal struct is internal
    end

    def updt_namespace norm_i, nss, yes_p
      nss.class.metastory.is_leaf and raise say_leaf_to_branch_error norm_i
      yes_p[ nss ]
      nss.do_skip and raise say_cannot_skip_already_opened_namespace ; nil
    end

    def add_ns norm_i, no_p
      nss = no_p[] or raise say_no_block_must_produce_namespace
      if nss.do_include
        @surface_mod[].story._scooper.add_name_at_this_point norm_i
        @box.add norm_i, nss
      else
        @skip_h[ norm_i ] = true
      end ; nil
    end

    def say_cant_add_namespace_to_open_command norm_i
      "can't add namespace when command is still open - #{ norm_i }"
    end

    def say_leaf_to_branch_error norm_i
      "attempt to reopen a command as a namespace - #{ norm_i }"
    end

    def say_cannot_skip_already_opened_namespace
      "cannot skip an already opened namespace."
    end

    def say_no_block_must_produce_namespace
      "cannot skip an already opened namespace."
    end

  protected

    def absrb_additional_namespace_definition a, p  # :#jump-1
      mp, xtra_x = prs_ns_args a
      mp || p and assrt_exactly_one mp, p
      xtra_x and absorb_extr xtra_x
      if mp
        absrb_module_proc mp
      elsif p
        absrb_module_def_p p
      end
    end

  private

    def absrb_module_proc mp
      @surface_mod_origin_i and raise "can't set a #{ MLF__ } to a #{
        }#{ NSM__ } that already originates with a #{ @surface_mod_origin_i }"
      @surface_mod_origin_i = :function
      @surface_mod = mp ; nil
    end

    def absrb_module_def_p p
      if @surface_mod_origin_i
        :blocks == @surface_mod_origin_i or raise say_wont_add xtra
        @block_a << p
      else
        @surface_mod_origin_i = :blocks
        @block_a = [ p ]
      end ; nil
    end

    def say_wont_add xtra
      @name and _ = " \"#{ @name.local_normal }\""
      "won't add a #{ DB__ } to #{ NSM__ }#{ _ } that was loaded via #{
        }#{ @surface_mod_origin_i }"
    end

    def bld_child_namespace_sheet norm_i, a, p  # :#jump-2
      nf = Lib_::Name_from_symbol[ norm_i ]
      mp, xtra_x = prs_ns_args a
      assrt_exactly_one mp, p
      if mp
        self.class.new( nil ).init_w_module_proc mp, nf, xtra_x
      else
        build_into p, nf, xtra_x
      end
    end

    def prs_ns_args a
      a.length.nonzero? && a.first.respond_to?( :call ) and mp = a.shift
      a.length.nonzero? and xtra_a = a  # can be a hash or an arg list
      [ mp, xtra_a ]
    end

    def assrt_exactly_one mp, p
      ( mp && p and d = 2 ) or ( ! ( mp || p ) and d = 0 )
      d and raise ::ArgumentError, say_must_have_one( d )
    end

    def say_must_have_one d
      "must have exactly 1 (#{ MLF__ } OR #{ DB__ }) - had #{ d }"
    end

    DB__ = "definition block"
    MLF__ = "module-loading function"
    NSM__ = "namespace module"

  protected

    def init_w_module_proc mp, nf, xtra_x
      @surface_mod = mp
      init_extndd_ns_sheet :function, nf, xtra_x
    end

  private

    def build_into block, name_func, xtra_x
      bm = box_mod_for @surface_mod[]
      co = name_func.as_const
      bm.const_defined?( co, false ) and raise "sanity - don't do this"
      sty = ( bm.const_set co, ::Class.new( Namespace ) ).story
      sty.init_w_block block, name_func, xtra_x
    end

    def box_mod_for sm
      if sm.const_defined? :Commands, false
        sm.const_get :Commands, false
      else
        sm.const_set :Commands, ::Module.new
      end
    end

  protected

    def init_w_block b, nf, xtra_x
      @block_a = [ b ]
      init_extndd_ns_sheet :blocks, nf, xtra_x  # overwrites `:module`, ok.
    end

  private

    def init_extndd_ns_sheet i, nf, xtra_x
      @hot = nil ;  @name = nf ; @surface_mod_origin_i = i
      xtra_x and absorb_extr xtra_x ; self
    end

  public

    def has_name
      @name
    end

    def name  # public like parent
      @name or fail say_who_want_name
    end

  private

    def say_who_wants_name s
      "who is asking for namefunc of #{ @surface_mod[] }?"
    end

  protected

  public

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
          r = svcs.pre_execute or svcs = r
          svcs
        end
      end
    end.call

    # ~ hacks

    def init_with_local_normal_name i  # for hacks, exploration
      @name and fail "won't clobber existing name"
      @name = Lib_::Name_from_symbol[ i ]
      self
    end
  end

  class NS_Mechanics_  # #re-open for 5.3x

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
        enhance_surface_with_h surface, h
      end
    end.call

    def self.__enhance surface, sheet, parent_services, slug
      new sheet, surface, parent_services, slug
    end
  end

  class NS_Sheet_   # ~ 5.3x.Nx ~

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
