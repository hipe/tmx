module Skylab::Callback::TestSupport::Autoloader

  module Const_Reduce

    module Fixtures::For_Skerlerb

      dpn = TS_.dir_pathname.join 'const-reduce/fixtures/for-skerlerb'
      define_singleton_method :dir_pathname do dpn end

    end
  end
end
