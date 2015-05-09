require_relative '../test-support'

module Skylab::Basic::TestSupport

  module Mdl_C___  # :+#throwaway-module for constants created here

    # <-

  TS_.describe "[ba] module" do

    context "value via relative path" do

      it "loads" do

        Basic_::Module
      end

      it "ok" do

        _subject( Basic_::Module, '..' ).should eql Basic_
      end

      it "when you dotdot above a toplevel path - nil" do

        _subject( ::Skylab, '..' ).should be_nil
      end

      def _subject mod, path

        Basic_::Module.value_via_relative_path mod, path
      end
    end

    it "does mutex" do

      module Zinger

        @a = []

        class << self
          attr_reader :a
        end

        define_singleton_method :push, Basic_::Module.mutex( -> x do
          @a <<  :"_#{ x }_"
        end )

      end

      Zinger.push :x

      Zinger.a.should eql %i( _x_ )

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
