module Skylab::Headless

  FUN = MetaHell::FUN::Module.new

  module FUN

    class Scn < ::Proc
      alias_method :gets, :call
      def self.[] p
        new( & p )
      end
    end

    o = definer

    # ~ the host system

    o[ :home_directory_path ] = -> do
      Headless::System.system.any_home_directory_path
    end

    o[ :home_directory_pathname ] = -> do
      Headless::System.system.any_home_directory_pathname
    end
  end

  def FUN.quietly                 # break the convention for readability :/
    x = $VERBOSE ; $VERBOSE = nil
    r = yield                     # catching / ensure is beyond this scope
    $VERBOSE = x
    r
  end                             # but [#mh-028] does it all
end
