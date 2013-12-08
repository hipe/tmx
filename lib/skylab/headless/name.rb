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

    Labelize = -> i do  # #tracked with [#088]
      i.to_s.gsub( /\A@|_[a-z]\z/, EMPTY_STRING_ ).
        gsub( '_', TERM_SEPARATOR_STRING_ ).sub( /\A[a-z]/, & :upcase )
    end

    o[:normify] = -> do           # make a const-looking string be normalized.
      rx = /(?<=[a-z])(?=[A-Z])|_|(?<=[A-Z])(?=[A-Z][a-z])/
      -> x { x.to_s.gsub( rx ) { '_' }.downcase.intern }
    end.call                      # ( part of the [#081] family )

    o[:slugulate] = -> i do       # for normals only. centralize this nerk
      i.to_s.gsub '_', '-'
    end

    o[:metholate] = -> i do       # in case your normal is a slug for some rsn.
      i.to_s.gsub '-', '_'
    end

    Naturalize = o[:naturalize] = -> i do      # for normals only, handles dashy normals
      i.to_s.gsub( /[-_]/, TERM_SEPARATOR_STRING_ )
    end

    Const_basename_ = o[:const_basename] = -> name_s do
      name_s[ name_s.rindex( ':' ) + 1 .. -1 ]
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

  private

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
    # from const to norm can be lossy (e.g `NCSA_Spy` -> `ncsa_spy` - it
    # is impossible to go in the reverse direction deterministically) :[#083]

    def self.from_name name
      new Name::Const_basename_[ name ].intern
    end

    def initialize const  # symbol! #api-lock [#032] : this signature.
      @const = const
      @local_normal = Headless::Name::FUN.normify[ const ] ; nil
    end

    def as_const
      @const
    end

    alias_method :local_slug, :as_slug  # so that this name function can
      # look like a full name function, if you want to future-proof your name
      # function but for now only use a const and not a deep graph.

  private

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

    def initialize a  # please provide an array of name functions
      @name_a = a
      nil
    end

    def length
      @name_a.length
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
  end

  class Name::Function::From::Module_Anchored < Name::Function::Full
    # (centralize this hacky fun here.)

  private

    def initialize n2, n1  # n2 - your module name  n1 - box module name
      0 == n2.index( n1 ) or raise "sanity - #{ n1 } does not contain #{ n2 }"
      name_a = if n2 == n1
        EMPTY_A_
      else
        n2[ n1.length + 2 .. -1 ].split( '::' ).reduce [] do |m, c|
          m << Name::Function::From::Constant.new( c ).freeze
        end
        # (because we reveal the constituents, we don't want to take chances)
      end
      super name_a
      nil
    end
  end
end
