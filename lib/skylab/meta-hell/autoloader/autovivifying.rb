module Skylab::MetaHell

  module Autoloader

    module Autovivifying  # read [#029] the autovivifying autoloader narr..

      define_singleton_method :[], Enhance_

      Methods = Autoloader::Methods

      ::Skylab::Autoloader[ self ]
    end
  end

  class Autoloader::Autovivifying::Const_Missing_ < Autoloader::Const_Missing_

    def self.enhance x
      const_missing_cls = self
      x.instance_exec do
        @const_missing_class ||= const_missing_cls
      end ; nil
    end

    def initialize( * )
      @autovivify_proc = nil
      super
    end

    attr_reader :mod_dir_pathname

    def autovivify_proc_notify p
      @autovivify_proc = p ; nil
    end

    def probably_loadable?
      super or @mod.has_stowaways && has_stowaway_resolver or
        branch_pathname.exist?
    end

    def branch_pathname
      @branch_pathname ||= leaf_pathname.sub_ext ''
    end

    def load_and_get correction=nil
      if @mod.has_stowaways && (( res_x = get_stowaway_resolver ))
        load_stowaway_and_get res_x
      elsif leaf_pathname.exist?
        super
      elsif branch_pathname.exist?
        if @autovivify_proc
          @autovivify_proc.call
        else
          @mod.const_set @const, build_autovivified_module
        end
      else
        raise ::LoadError, "uninitialized constant #{ @mod }::#{ @const } #{
          }and no such directory [file] to autoload -- #{
          }#{ pth @branch_pathname }[#{ Autoloader::EXTNAME }]"
      end
    end

    def build_autovivified_module
      bpn = branch_pathname ; const_missing_class = self.class
      ::Module.new.module_exec do
        extend Autoloader::Methods
        const_missing_class.enhance self
        @dir_pathname = bpn
        self
      end
    end

  private

    def pth pathname
      pathname.relative_path_from ::Skylab.dir_pathname
    end

    # read [#029]:#the-stowaway-experiment

    [ :has_stowaway_resolver, :get_stowaway_resolver ].each do |i|
      define_method i do
        enhance_self_for_stowaways
        send i  # ( this is distinct from `Magic_Touch_` [#fa-046] in that
      end       #   we load something once per instance, not once per class. )
      private i
    end

    def enhance_self_for_stowaways  # only ever called once per instance.
      define_singleton_method :enhance_self_for_stowaways do fail 'no' end

      stow_a = @mod.stowaway_a_a or fail "sanity - no stowaways in #{ @mod }"

      get_res = -> do             # find the correct "record" of `stow`
        resolver_x = stow_a.reduce nil do | _, ( *guest_a, loc_x ) |
          break loc_x if guest_a.include? @const
        end
        get_res = -> { resolver_x }
        resolver_x
      end

      define_singleton_method :has_stowaway_resolver do get_res[] end

      define_singleton_method :get_stowaway_resolver do get_res[] end

      define_singleton_method :load_stowaway_and_get do |res_x|
        m = @mod ; c = @const
        if res_x.respond_to? :call
          x = res_x.call
          m.const_defined? c, false or m.const_set c, x
        elsif res_x.respond_to? :ascii_only?
          require "#{ m.dir_pathname.join res_x }"
        else
          [ * res_x ].reduce( m ) do |mod, i|
            mod.const_get i, false
          end
        end
        m.const_defined?( c, false ) or raise ::LoadError, "`#{ m }::#{ c }` #{
          }as a stowaway loaded via \"#{ res_x }\" was expected but not #{
           }resolved via that means."
        m.const_get c, false
      end
    end
  end
end
