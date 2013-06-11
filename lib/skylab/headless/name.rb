module Skylab::Headless

  module Name                     # a fresh new spin on an old favorite

    o = { }

    # **NOTE** the below have a much more narrow set of allowable
    # input data that inflection methods you might find elsewhere in
    # the system.

    o[:constantify] = -> do       # make a normalized symbol look like a const
      rx = /(?:^|[-_])([a-z])/
      -> x { x.to_s.gsub( rx ) { $~[1].upcase } }
    end.call

    o[:normify] = -> do           # make a const-looking string be normalized.
      rx = /(?<=[a-z])(?=[A-Z])|_|(?<=[A-Z])(?=[A-Z][a-z])/
      -> x { x.to_s.gsub( rx ) { '_' }.downcase.intern }
    end.call

    o[:slugulate] = -> i do       # for normals only. centralize this nerk
      i.to_s.gsub '_', '-'
    end

    o[:metholate] = -> i do       # in case your normal is a slug for some rsn.
      i.to_s.gsub '-', '_'
    end

    o[:naturalize] = -> i do      # for normals only, handles dashy normals
      i.to_s.gsub '-_', ' '
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze
  end

                                               # construct one given a
  class Name::Function                         # local_normalize_name and you
                                               # get two fabulous methods

    def self.from_const const                  # build a new name function
      Name::Function::From::Constant.new const # a constant. convenience
    end                                        # accessor. see.

    attr_reader :local_normal

  protected

    def initialize local_normal       # (consider freezing your n.f)
      @local_normal = local_normal
    end
  end
                                               # if you buy-in to the idea of
                                               # defining local_normal
                                               # as being lower-cased and
  module Name::Function::InstanceMethods       # underscored, we will give
                                               # you these methods. here have
    def as_const                               # them
      Name::FUN.constantify[ local_normal ].intern
    end

    def as_method
      Name::FUN.metholate[ local_normal ].intern  # or even if slug-
    end                                        # some applications annoyingly
                                               # allow for slug-looking normals
    def as_slug
      Name::FUN.slugulate[ local_normal ]
    end

    def as_natural
      Name::FUN.naturalize[ local_normal ]
    end
  end

  class Name::Function
    include Name::Function::InstanceMethods
  end

  module Name::Function::From
  end  # cute

  class Name::Function::From::Constant < Name::Function

    # constant names can hold more information than others, so converting
    # from const to norm can be lossy (e.g `NCSA_Spy` -> `ncsa_spy`. going
    # in the reverse direction deterministically is impossible!)

    def self.from_name name
      new name[ name.rindex( ':' ) + 1 .. -1 ]
    end

    def as_const
      @const
    end

    alias_method :local_slug, :as_slug  # so that this name function can
      # look like a full name function, if you want to future-proof your name
      # function but for now only use a const and not a deep graph.

  protected

    def initialize const # symbol!
      @const = const
      @local_normal = Headless::Name::FUN.normify[ const ]
      nil
    end

    def base_init const, local_normal
      @const = const  # symbol!
      @local_normal = local_normal
      nil
    end

    def base_args
      [ @const, @local_normal ]
    end
  end

  class Name::Function::Full  # abstract representation of fully-qualified names

    def self.from_normalized_name_path a
      a.map(& Name::Function.method( :new ) )
    end

    def local
      @name_a.last
    end

    def map sym  # for now we protect constituents by doing it like this
      @name_a.map(& sym )
    end

    def anchored_normal
      @anchored_normal ||= @name_a.map(& :local_normal ).freeze
    end

    def initialize a  # please provide an array of name functions
      @name_a = a
      nil
    end
  end

  module Name::Function::From::Module
  end  # no

  class Name::Function::From::Module::Graph < Name::Function::Full
    # (centralize this hacky fun here.)

  protected

    def initialize n2, n1  # n2 - your module name  n1 - box module name
      0 == n2.index( n1 ) or raise "sanity - #{ n1 } does not contain #{ n2 }"
      name_a = n2[ n1.length + 2 .. -1 ].split( '::' ).reduce [] do |m, c|
        m << Name::Function::From::Constant.new( c ).freeze
      end  # (because we reveal the constituents, we don't want to take chances)
      super name_a
      nil
    end
  end
end
