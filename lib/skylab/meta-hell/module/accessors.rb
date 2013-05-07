module Skylab::Face

  module Services::ModuleAccessors

    # NOTE requires MAARS for now..

    def self.enhance host_mod, &enhance_blk

      cnd = Conduit_.new( -> access, meth, path, create_blk, extend_blk do

        ivar = "@#{ meth }".intern

        host_mod.send :define_method, meth do
          if instance_variable_defined? ivar
            instance_variable_get ivar
          else
            path_a = self.class.name.split '::'
            delt_a = path.split '/'
            while part = delt_a.shift
              if '..' == part
                path_a.pop
              else
                path_a.push part
              end
            end
            modul = path_a.reduce ::Object do |m, s|
              if m.const_defined? s, false
                m.const_get s, false
              elsif m.const_probably_loadable? s  # etc
                mod = m.const_get s, false
                if extend_blk
                  mod.module_exec( & extend_blk )  # future i am sorry
                end
                mod
              elsif create_blk
                m.const_set s, create_blk.call
              else
                m.const_get s, false  # trigger the error, presumably
              end
            end
            instance_variable_set ivar, modul
          end
        end

        if access
          host_mod.send access, meth
        end

        nil
      end )
      cnd.instance_exec( & enhance_blk  )
      nil
    end

    class Conduit_

      def initialize mod_bumper
        @stack = []
        @mod_bumper = mod_bumper
      end

      def module_reader meth, path, &blk
        @mod_bumper[ @stack.last, meth, path, nil, blk ]
      end

      def module_autovivifier meth, path, &blk
        @mod_bumper[ @stack.last, meth, path, blk, nil ]
      end

      def private_methods &blk
        with_access :private, blk
      end

      def protected_methods &blk
        with_access :protected, blk
      end

      def public_methods &blk
        with_access :public, blk
      end

      def with_access i, blk
        @stack.push i
        instance_exec( &blk )
        @stack.pop
        nil
      end
    end
  end
end
