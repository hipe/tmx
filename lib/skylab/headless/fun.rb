module Skylab::Headless

  FUN = Headless_::Lib_::FUN_module[].new

  module FUN

    Inspect = -> x do
      Headless::Library_::Basic::FUN::Inspect[ x ]
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
