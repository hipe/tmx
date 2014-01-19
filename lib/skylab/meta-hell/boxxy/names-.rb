module Skylab::MetaHell

  module Boxxy::Names_

    class Fly__ < MetaHell::Library_::Headless::Name::Function::From::Constant

      alias_method :replace_fly_with_const, :initialize
      public :replace_fly_with_const
      def initialize
      end
    end
  end

  module Boxxy::MM__

    undef_method :names

    the_only_fly = -> do
      fly = Boxxy::Names_::Fly__.new
      the_only_fly = -> { fly }
      fly
    end

    define_method :names do
      fly = the_only_fly[]
      ::Enumerator.new do |y|
        constants.each do |const_i|
          fly.replace_fly_with_const const_i
          y << fly
        end
      end
    end
  end
end
