module Skylab::Headless
  module Name                     # a fresh new spin on an old favorite
    o = { }

    o[:constantify] = -> do # (tighter version for the sake of simplicity)
      rx = /(?:^|[-_])([a-z])/
      -> x { x.to_s.gsub( rx ) { $~[1].upcase } }
    end.call


    o[:pathicate] = -> do # not as full but might be an improvement
      rx = /(?<=[a-z])(?=[A-Z])|_|(?<=[A-Z])(?=[A-Z][a-z])/
      -> x { x.to_s.gsub( pathify_rx ){ '-' }.downcase }
    end.call

    o[:methodate] = -> x do
      o[:pathicate][x].gsub( '-', '_' ).intern
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze
  end

  module Name::Function                        # if you buy-in to the idea of
  end                                          # defining normalized_local_name
                                               # as being lower-cased and
  module Name::Function::InstanceMethods       # underscored, we will give
                                               # you these methods. here have
                                               # them
    def to_const
      Name::FUN.constantify[ normalized_local_name ].intern
    end

    def to_slug
      normalized_local_name.to_s.gsub '_', '-'
    end
  end
end
