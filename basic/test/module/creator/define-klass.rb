module Skylab::Basic::TestSupport

  module Module::Creator

    Define_Klass = -> tcm, _BOX_MOD do

      sbox_class_counter = 0

      tcm.send :define_singleton_method, :define_klass_ do | & eval_p |

        let :klass_ do

          ::Class.new.class_eval do

            _BOX_MOD.const_set(
              :"Generated_Sandbox_Class__#{ sbox_class_counter += 1 }__",
              self )

            class << self
              TestSupport_::Let[ self ]  # EEK the class itself must memoize
            end

            sbox_mod_counter = 0

            define_method :initialize do

              @___my_box_mod = self.class.const_set(

                :"Generated_Sandbox_Module__#{ sbox_mod_counter += 1 }__",
                ::Module.new )
            end

            TestSupport_::Let[ self ]  # EEK and the instance

            Home_::Module::Creator[ self ]

            if eval_p
              class_exec( & eval_p )
            end

            m = :meta_hell_anchor_module
            if ! method_defined? m
              define_method m do
                @___my_box_mod
              end
            end

            self
          end
        end
      end
    end
  end
end
