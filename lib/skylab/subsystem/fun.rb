module Skylab

  module Subsystem

    module FUN

      o = -> i, p do
        define_singleton_method i do p end
        p
      end
      class << o ; alias_method :[]=, :[] end

      o[ :require_quietly ] = -> s do   # load a warning-noisy library
        Subsystem::Subsystems_::MetaHell::FUN.without_warning do
          require s
        end
      end

      o[ :require_stdlib ] = o[ :require_gemlib ] = -> const_i do
        require const_i.downcase.to_s
        ::Object.const_get const_i
      end

      o[ :require_subsystem ] = -> const_i do
        Subsystem::Subsystems_.require_subsystem const_i
      end

      def self.at *a
        a.map( & method( :send ) )
      end
    end
  end
end
