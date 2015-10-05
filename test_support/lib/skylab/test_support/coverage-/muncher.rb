module Skylab::TestSupport

  module Coverage_::Muncher

    def self.munch *a
      a.reduce MUNCH.curry do |f, x|
        f[ x ]
      end
    end

    MUNCH = -> path_prefix_proc, switch, infostream, argv do
      idx = argv.index switch
      if idx
        argv[ idx, 1 ] = []
        Coverage_::Service.start infostream, path_prefix_proc
      end
      nil
    end
  end
end
