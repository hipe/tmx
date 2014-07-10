module Skylab::MetaHell

  module Autoloader::Autovivifying::Recursive  # read [#031] the MAARS nar.

    Methods = Autoloader::Methods

    def self.[] mod, *a
      loc = if a.length.zero?
        if mod.instance_variable_defined? :@dir_pathname
          :none
        else
          caller_locations( 1, 1 ).first
        end
      elsif (( x = a.first )) and x.respond_to? :base_label
        a.shift
      else
        :none
      end
      _enhance mod, * loc
      a.length.zero? or mod.const_missing_class.reify_options a, mod
      nil
    end
    define_singleton_method :_enhance, & Autoloader::Enhance_

    module Bundles_
      Deferred = -> do
        singleton_class.class_exec do
          alias_method :_, :dir_pathname
          undef_method :dir_pathname
          define_method :dir_pathname do
            singleton_class.class_exec do
              undef_method :dir_pathname
              alias_method :dir_pathname, :_
            end
            Upwards[ self ]
            @dir_pathname
          end
        end
      end
    end

    class Const_Missing_ < Autoloader::Autovivifying::Const_Missing_

      def load_and_get correction=nil
        @x = super
        do_enhance = if @x.respond_to? :dir_pathname
          true
        elsif ::Module === @x
          @x.extend Autoloader::Methods
          true
        end
        do_enhance and enhance_loadee
        @x
      end
    private
      def enhance_loadee
        tug = self
        @x.module_exec do
          dir_pathname.nil? and init_dir_pathname tug.branch_pathname
          # let module graphs charge passively just after file load
          const_missing_class.nil? and tug.class.enhance self
        end ; nil
      end

      def self.reify_options a, mod
        self::Reification__.new( a, mod ).execute
      end
    end

    class Const_Missing_::Reification__
      def initialize a, mod
        @a = a ; @mod = mod
      end
      def execute
        if @a.first.respond_to? :relative_path_from
          @mod.init_dir_pathname @a.shift
        end
        while @a.length.nonzero?
          send :"#{ @a.shift }="
        end ; nil
      end
    private
      def deferred=
        @mod.module_exec( & Bundles_::Deferred )
      end
      def methods=  # did
      end
    end
  end

  module Autoloader::Autovivifying::Recursive::Upwards

    def self.[] mod  # #storypoint-90, #idempotent
      Flush_stack__[ Build_stack_from_mod__[ mod ] ]
    end

    Build_stack_from_2_mods__ = -> mod1, mod do
      stack_a = [ * mod1 ] ; top_has_dpn = false
      while ! ( mod.respond_to? :dir_pathname and mod.dir_pathname )
        stack_a.push mod
        mod.instance_variable_defined? :@dir_pathname and
          break( top_has_dpn = true )
        mod = Surrounding_module__[ mod ]
      end
      top_has_dpn and MAARS[ stack_a.pop ]
      stack_a << mod
    end

    Build_stack_from_mod__ = Build_stack_from_2_mods__.curry[ nil ]

    Surrounding_module__ = -> mod do
      MetaHell_::Module::Resolve[ '..', mod ] or
        raise "can't - rootmost module (::#{ mod }) has no dir_pathname"
    end

    Flush_stack__ = -> stack_a do
      mod = stack_a.pop
      while mod_ = stack_a.pop
        n = mod_.name
        mod_.module_exec do
          @dir_pathname = mod.dir_pathname.join(
            ::Skylab::Autoloader::FUN::Pathify[
              n[ n.rindex( ':' ) + 1 .. -1 ] ] )
          MAARS[ self ]
        end
        mod = mod_
      end
      nil
    end
  end
end
