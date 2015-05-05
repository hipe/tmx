module Skylab::InformationTactics

  module Library_

    class << self

      def touch i
        if ! const_defined? i, false
          const_get i, false
        end ; nil
      end
    end  # >>

    -> o do

      gemlib = stdlib = Autoloader_.method :require_stdlib

      o[ :Levenshtein ] = gemlib

      o[ :Time ] = stdlib

    end.call -> do
      o = {}
      define_singleton_method :const_missing do |i|
        const_set i, o.fetch( i )[ i ]
      end
      o
    end.call
  end
end
