module Skylab::MetaHell

  module Autoloader::Autovivifying

    extend Autoloader_            # myself? i'm a basic autoloader.

    def self.extended mod
      mod.module_exec do
        extend Autoloader_::Methods
        @tug_class = Autoloader::Autovivifying::Tug
        init_autoloader caller[2]  # location of call to `extend`!
      end
      nil
    end
  end

  class Autoloader::Autovivifying::Tug < Autoloader_::Tug

    def load f=nil                # compare to super
      if leaf_pathname.exist?     # we don't expose this to hacking -
        load_file f               # if this file doesn't have the const,
                                  # it very likely should.
      elsif @mod.has_stowaways and (( loc_x = get_stowaway_location ))
        load_stowaway loc_x       # stowaways need to trump autovivification
                                  # of branch-node ("box") type modules

      elsif branch_pathname.exist?
        @mod.const_set @const, build_autovivified_module
        true
      else
        raise ::NameError, "uninitialized constant #{ @mod }::#{ @const } #{
          }and no such directory [file] to autoload -- #{
          }#{ pth @branch_pathname }[#{ Autoloader_::EXTNAME }]"
      end
    end

    def probably_loadable?
      super or
        @mod.has_stowaways && has_stowaway_location or
        branch_pathname.exist?
    end

  private

    #         ~ private method support, pre order ~

    def branch_pathname
      @branch_pathname ||= leaf_pathname.sub_ext ''
    end

    def build_autovivified_module
      bpn = branch_pathname ; me = self
      ::Module.new.module_exec do
        extend Autoloader_::Methods
        @tug_class = me.class
        @dir_pathname = bpn
        self
      end
    end

    def pth pathname
      pathname.relative_path_from ::Skylab.dir_pathname
    end

    #                       ~ the stowaway experiment ~

    # the `stowaway` facility :[#030] facilitates the dubious behavior of
    # "defining" a given module in a file other than the file you would expect
    # to find the module in (i.e in violation of `isomorphic file location`
    # [#029]). #experimental

    # a "record" is created in the "stowaway manifest" when `stowaway` is
    # called on a module. each record is a tuple of the form (*guest_a, loc_x)
    # where `loc_x` represents a loading strategy and `guest_a` is a list
    # of symbols representing constants defined immediately under @mod
    # but residing in `loc_x`:
    #
    #   [ :Foo, :Bar, :Baz ]  # =>
    #                         # to get @mod::Foo or @mod::Bar load @mod::Baz
    #   [ :Biff, 'luhrman' ]  # => to get @mod::Biff, do
    #                         # `require "#{ dirpn }/luhrman"`


    [ :has_stowaway_location, :get_stowaway_location ].each do |i|
      define_method i do
        enhance_self_for_stowaways
        send i  # ( this is distinct from `Magic_Touch_` [#fa-046] in that
      end       #   we load something once per instance, not once per class. )
      private i
    end

    def enhance_self_for_stowaways  # only ever called once per instance.
      define_singleton_method :enhance_self_for_stowaways do fail 'no' end

      stow_a = @mod.stowaway_a or fail "sanity - no stowaways in #{ @mod }"

      get_loc = -> do             # find the correct "record" of `stow`
        location_x = stow_a.reduce nil do | _, ( *guest_a, loc_x ) |
          break loc_x if guest_a.include? @const
        end
        get_loc = -> { location_x }
        location_x
      end

      define_singleton_method :has_stowaway_location do get_loc[] end
      define_singleton_method :get_stowaway_location do get_loc[] end
      define_singleton_method :load_stowaway do |loc_x|
        if loc_x.respond_to? :ascii_only?
          require "#{ @mod.dir_pathname.join loc_x }"
        else
          [ * loc_x ].reduce( @mod ) do |m, x|
            m.const_get x, false
          end
        end
        # (for now we avoid using c-onst_defined? out of deference for
        # one possible spot [#ta-078])
        if @mod.constants.include? @const then true else
          raise ::NameError, "`#{ @mod }::#{ @const }` as a stowaway #{
            }under \"#{ loc_x }\" was expected but not found there."
        end
      end
    end
  end
end
