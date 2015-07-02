module Skylab::Face

  module CLI

    class << self

      def reparenthesize
        self::Client::Reparenthesize
      end

      def stylify
        LIB_.brazen::CLI::Styling::Stylify
      end
    end

    module Lib_

      include Home_::Lib_

    end
  end
end
# this file used to be Skylab::Face::CLI::External_Dependencies. #tombstone
