module Skylab::Fields::TestSupport

  module Entity

    # (this is mostly used for its constants)

    class << self

      def [] tcc
        tcc.include self
      end

      def lib

        # this method is how we reach the asset node from within artifact
        # modules in tests. reaching it in this way:
        #
        #   - insulates us from name/location change
        #
        #   - does not require the toplevel test support node to know us

        Home_::Entity
      end
    end  # >>

    # -

      def subject_library_
        Home_::Entity
      end
    # -

    # == enhancer functions

    Define_common_initialize_and_with = -> mod do

      mod.send :define_method, :initialize, DEFINITION_FOR_THE_METHOD_CALLED_INITIALIZE__

      mod.send :define_singleton_method, :with, DEFINITION_FOR_THE_METHOD_CALLED_WITH

      mod
    end

    Enhance_for_test = -> mod do
      mod.send :define_singleton_method, :with, DEFINITION_FOR_THE_METHOD_CALLED_WITH
      mod.include TestInstanceMethods
      mod
    end

    # == method definitions

    DEFINITION_FOR_THE_METHOD_CALLED_WITH = -> * x_a do
      ok = nil
      x = new do
        ok = process_argument_scanner_fully(
          Home_::Scanner_[ x_a ] )
      end
      ok && x
    end

    DEFINITION_FOR_THE_METHOD_CALLED_INITIALIZE__ = -> & p do
      instance_exec( & p )
    end

    # == modules

    module TestInstanceMethods

      define_method :initialize, DEFINITION_FOR_THE_METHOD_CALLED_INITIALIZE__

      def process_fully_for_test_ * x_a

        _scn = Home_::Scanner_[ x_a ]

        process_argument_scanner_fully _scn
      end
    end

    # ==
    # ==
  end
end
# #history: full rewrite: no more sandbox module.
