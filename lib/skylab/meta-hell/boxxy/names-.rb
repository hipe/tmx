module Skylab::MetaHell

  module Boxxy::Names_

    def self.load
    end

    class Fly_ < MetaHell::Services::Headless::Name::Function::From::Constant

      alias_method :replace, :initialize ; public :replace  # [#mh-031]
      def initialize ; end  # poof you're a flyweight

      def dupe
        ba = base_args
        self.class.allocate.instance_exec do
          base_init(* ba )
          self
        end
      end
    end
  end

  module Boxxy::ModuleMethods_

    undef_method :names

    the_only_fly = -> do
      fly = Boxxy::Names_::Fly_.new
      the_only_fly = -> { fly }
      fly
    end

    define_method :names do
      fly = the_only_fly[]
      ::Enumerator.new do |y|
        constants.each do |const|
          fly.replace const
          y << fly
        end
      end
    end
  end
end
