module Skylab::Headless

  o = { }

  #         ~ functions that pertain to the underlying system ~

  o[:home_directory_path] = -> do
    Headless::System.system.any_home_directory_path
  end

  o[:home_directory_pathname] = -> do
    Headless::System.system.any_home_directory_pathname
  end

  FUN = ::Struct.new( * o.keys ).new( * o.values )

  def FUN.quietly                 # break the convention for readability :/
    x = $VERBOSE ; $VERBOSE = nil
    r = yield                     # catching / ensure is beyond this scope
    $VERBOSE = x
    r
  end                             # but [#mh-028] does it all
end
