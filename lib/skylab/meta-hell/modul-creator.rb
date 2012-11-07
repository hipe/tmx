module Skylab::MetaHell
  module ModulCreator
    def self.extended mod                                             # #sl-109
      mod.extend        ModulCreator::ModuleMethods
      mod.send :include, ModulCreator::InstanceMethods
    end

    SEP = '__'
  end


  module ModulCreator::ModuleMethods
    # *note* this does not exclusively pull in a let() implementation,
    # but expects one.

    include ModulCreator # #constants

    def modul full_name, &f
      # make definitions for each nesting module too:
      #
      #   Foo::Bar::Baz => "Foo", "Foo::Bar", "Foo::Bar::Baz"
      #

      parts = full_name.to_s.split SEP
      last = parts.length - 1
      memo = nil
      parts.each_with_index do |x, i|
        name = memo = [memo, x].compact.join( SEP )
        if last == i
          __meta_hell_module!(name) { modul!(name, &f) }
        else
          __meta_hell_module!(name) { modul!(name, full_name, &f) }
        end
      end
      nil
    end

    def __meta_hell_module! full_module_name, &f
      ___meta_hell_memoize_module full_module_name, &f
      ___meta_hell_define_module_convenience_accessor full_module_name
      nil
    end

    def ___meta_hell_define_module_convenience_accessor full_module_name
      # _Foo self.Foo send(:Foo)
      define_method( "_#{full_module_name}" ) { send full_module_name }
    end

    def ___meta_hell_memoize_module full_module_name, &f
      # memoize the module (e.g. class) around this very definition call
      # together with the anchor moudle.  Memoizing on the client alone will
      # get you possibly repeated definition block runs depending on how
      # you implement that .. in flux!

      memo_h = { }

      let full_module_name do
        memo_h.fetch( meta_hell_anchor_module.object_id ) do |mod|
          memo_h[mod] = instance_exec(& f)
        end
      end
    end
  end


  module ModulCreator::InstanceMethods
    extend MetaHell::Let::ModuleMethods

    def _module! const_a
      # Make these modules now iff not defined, recursive.
      const_a.reduce meta_hell_anchor_module do |mod, const|
        if ! mod.const_defined? const, false
          m = ::Module.new
          _my_name = (mod == meta_hell_anchor_module) ? const.to_s : "#{mod}::#{const}"
          m.singleton_class.send(:define_method, :to_s) { _my_name }
          mod.const_set const, m
        end
        mod.const_get const, false
      end
    end

    def modul! full_name, deepest_child_full_name=nil, &body_f
      # Get this module by name now, autovifiying parent modules as required,
      # and kicking children along the way (see tests).  Run any block against
      # the requested module, possibly redundantly if that's what u are doing.

      mod = _module! full_name.to_s.split('__')
      if deepest_child_full_name
        modul! deepest_child_full_name, &body_f
      elsif body_f
        mod.module_exec(self, &body_f)
      end
      mod
    end
  end
end
