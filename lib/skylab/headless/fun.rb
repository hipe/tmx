module Skylab::Headless

  o = { }

  #         ~ functions that pertain to the ruby runtime ~

  # #todo:ruby-2.0.0-ify - the below can be cleaned up

  o[:call_frame_rx] = /
      #{ Autoloader::Inflection::FUN.call_frame_path_rx.source } :
      (?<no>\d+) : in [ ] ` (?<meth>[^']+) '
    \z/x

  o[:require_quietly] = -> s do   # Useful to load libraries that are not
    FUN.quietly { require s }     # warning friendly
  end

  #         ~ functions that pertain to the underlying system ~

  o[:home_directory_path] = -> do
    ::ENV['HOME']
  end

  o[:home_directory_pathname] = -> do
     s = FUN.home_directory_path[] and ::Pathname.new( s )
  end

  FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v }

  def FUN.quietly                 # break the convention for readability :/
    v = $VERBOSE
    $VERBOSE = nil
    r = yield                     # catching / ensure is beyond this scope
    $VERBOSE = v
    r
  end
end
