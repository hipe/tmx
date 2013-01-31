require_relative '..'

module Skylab
  module MetaHell
    MetaHell = self
    extend ::Skylab::Autoloader
    module Autoloader
      extend ::Skylab::Autoloader
    end
    extend MetaHell::Autoloader::Autovivifying::ModuleMethods # MWAHAHAHA stupid
  end

  module MetaHell::Proxy
    extend MetaHell::Autoloader::Autovivifying # dumb, meet dumber. when you
    class << self                              # break this life will suck
      def Ad_Hoc h
        self::Ad_Hoc.new h  # just say it you hate me now
      end                                      # the reason this is here and
    end                                        # not there or the other place
  end                                          # is because of orphans and
end                                            # autoloading, respectively
