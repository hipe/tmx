module Skylab::Face

  module CLI

    class << self

      def reparenthesize
        self::Client::Reparenthesize
      end

      def stylify
        Lib_::CLI_lib[].pen.stylify
      end

      def tableize rows, p=nil, opts={}, & p_
        a = [ p, p_ ]
        a.compact!
        p = a.fetch a.length - 1 << 1
        CLI::Tableize__[ opts, p, rows ]
      end
    end

    module Lib_

      include Face_::Lib_

    end
  end
end
# this file used to be Skylab::Face::CLI::External_Dependencies. #tombstone
