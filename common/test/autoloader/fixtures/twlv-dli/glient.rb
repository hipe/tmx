module Skylab::Common::TestSupport::Autoloader
  module Fixtures::Twlv_DLI::Glient
    dpn = TS_.dir_pathname.join 'xy/zzy'
    define_singleton_method :dir_pathname do dpn end
  end
end