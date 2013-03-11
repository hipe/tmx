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
      if leaf_pathname.exist?
        load_file f
      elsif branch_pathname.exist?
        @mod.const_set @const, build_autovivified_module
        true
      elsif ! stowaway
        raise ::NameError, "uninitialized constant #{ @mod }::#{ @const } #{
          }and no such directory [file] to autoload -- #{
          }#{ pth @branch_pathname }[#{ Autoloader_::EXTNAME }]"
      end  # (result is result of callee)
    end

    def probably_loadable?
      super or branch_pathname.exist?
    end

  protected

    #         ~ public method support, pre order ~

    def branch_pathname
      @branch_pathname ||= leaf_pathname.sub_ext ''
    end

    def build_autovivified_module
      me = self
      ::Module.new.module_exec do
        extend Autoloader_::Methods
        @tug_class = me.class
        @dir_pathname = me.send :branch_pathname
        self
      end
    end

    def pth pathname
      pathname.relative_path_from ::Skylab.dir_pathname
    end

    #         ~ the stowaway experiment ~

    def stowaway
      stow_a = @mod.send :stowaway_a
      if stow_a
        host_const = stow_a.reduce nil do |_, (*guest_a, host)|
          break host if guest_a.include? @const
        end
        if host_const
          # assume that `host_const` represents a loadable but not yet loaded
          # node that holds the definition for both `host_const` and @const.
          # let's let the module decide the tug class, as we hack this:
          tug = @mod.tug_class.new host_const, @mod_dir_pathname, @mod
          if tug.load   # (else it borked, for now)
            # (for now we avoid usuing c-onst_defined? out of deference for
            # one possible spot [#ta-078])
            if @mod.constants.include? @const
              true
            else
              raise ::NameError, "#{ @mod }::#{ @const }, as a stowaway #{
                }under #{ host_const }, was expected but not found in #{
                }#{ pth tug.leaf_pathname }"
            end
          end
        end
      end
    end
  end
end
