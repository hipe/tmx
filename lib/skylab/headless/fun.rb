module Skylab::Headless
  o = { }

  o[:require_quietly] = -> s do   # Useful to load libraries that are not
    FUN.quietly { require s }     # warning friendly
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
