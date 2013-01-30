module Skylab::Headless
  module Name                     # a fresh new spin on an old favorite
    o = { }

    o[:constantify] = -> do # (tighter version for the sake of simplicity)
      rx = /(?:^|[-_])([a-z])/
      -> x { x.to_s.gsub( rx ) { $~[1].upcase } }
    end.call


    o[:pathicate] = -> do # not as full but might be an improvement
      rx = /(?<=[a-z])(?=[A-Z])|_|(?<=[A-Z])(?=[A-Z][a-z])/
      -> x { x.to_s.gsub( rx ){ '-' }.downcase }
    end.call

    o[:methodate] = -> x do
      o[:pathicate][x].gsub( '-', '_' ).intern
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze
  end

                                               # construct one given a
  class Name::Function                         # normalized_local_name and you
                                               # get two fabulous methods

    def self.from_const const                  # build a new name function
      Name::Function::From::Constant.new const # a constant. convenience
    end                                        # accessor. see.

    attr_reader :normalized_local_name

  protected

    def initialize normalized_local_name
      @normalized_local_name = normalized_local_name
    end
  end
                                               # if you buy-in to the idea of
                                               # defining normalized_local_name
                                               # as being lower-cased and
  module Name::Function::InstanceMethods       # underscored, we will give
                                               # you these methods. here have
    def to_const                               # them
      Name::FUN.constantify[ normalized_local_name ].intern
    end

    def to_slug
      normalized_local_name.to_s.gsub '_', '-'
    end
  end

  class Name::Function
    include Name::Function::InstanceMethods
  end

  module Name::Function::From
  end # cute

  class Name::Function::From::Constant < Name::Function
    # constant names can hold more information than others, so converting
    # from const to norm can be lossy.

    def to_const
      @const
    end

  protected

    def initialize const
      @const = const
      @normalized_local_name = Headless::Name::FUN.methodate[ const ]
    end
  end
end
