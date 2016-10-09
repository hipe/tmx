module Skylab::Basic::TestSupport

  module Class::Creator

    class << self

      def [] tcm, box_mod

        TestSupport_::Let[ tcm ]

        tcm.extend ModuleMethods

        tcm.let :o do
          self.klass.new
        end

        tcm.send :define_singleton_method, :snip, Build_Snip_Method___[ box_mod ]

        NIL_
      end
    end  # >>

    # <-

  module ModuleMethods

    def borks msg
      it "raises error with message - #{ msg }" do
        -> do
          subject.call
        end.should raise_error( msg )
      end
    end

    def doing &f
      let :subject do
        -> { instance_exec(& f) } # yeah, wow
      end
    end
  end

  Build_Snip_Method___ = -> box_mod do

    counter = 0

    -> & f do

      let :klass do

        ::Class.new.class_eval do

          Home_::Class::Creator[ self ]

          define_method :memoized_, TestSupport_::Let::MEMOIZED_METHOD

          let :meta_hell_anchor_module do

            box_mod.const_set(
              :"Gennd_Box_Mod__#{ counter += 1 }__",
              ::Module.new )
          end

          class_exec(& f) if f

          self
        end
      end
    end
  end

# ->
  end
end
