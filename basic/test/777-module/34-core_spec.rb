require_relative '../test-support'

module Skylab::Basic::TestSupport

  module Mdl_C___  # :+#throwaway-module for constants created here

    # <-

  TS_.describe "[ba] module" do

    context "value via relative path" do

      it "loads" do

        Home_::Module
      end

      it "ok" do

        expect( _subject( Home_::Module, '..' ) ).to eql Home_
      end

      it "when you dotdot above a toplevel path - nil" do

        expect( _subject( ::Skylab, '..' ) ).to be_nil
      end

      def _subject mod, path

        Home_::Module.value_via_relative_path mod, path
      end
    end

    it "does mutex" do

      module Zinger

        @a = []

        class << self
          attr_reader :a
        end

        define_singleton_method :push, Home_::Module.mutex( -> x do
          @a <<  :"_#{ x }_"
        end )

      end

      Zinger.push :x

      expect( Zinger.a ).to eql %i( _x_ )

      _rx = /\bmodule mutex failure .+\bZinger\b/

      begin
        Zinger.push :y
      rescue ::RuntimeError => e
      end

      if _rx !~ e.message
        raise e
      end
    end
  end
# ->
  end
end
