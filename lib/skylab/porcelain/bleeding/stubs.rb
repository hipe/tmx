module Skylab::Porcelain::Bleeding
  module Stubs
    def self.extended mod
      mod.extend Stubs::ModuleMethods
      mod.send :_bleeding_stubs_init!, caller[0]
    end
  end

  module Stubs::ModuleMethods
    include ::Skylab::Autoloader::ModuleMethods

    def constants
      @constants or read_fs
      @constants
    end

    if false
    pathify = -> do # #todo this might actually be an improvement
      rx = /(?<=[a-z])(?=[A-Z])|_|(?<=[A-Z])(?=[A-Z][a-z])/
      -> x { x.to_s.gsub( rx ){ '-' }.downcase }
    end.call
    end

  protected

    def _bleeding_stubs_init! callr
      _autoloader_init! callr
      class << self
        alias_method :bleeding_stubs_original_constants, :constants
        alias_method :bleeding_stubs_original_const_get, :const_get
      end
      @constants = nil
    end

    # (haha posterity - look what we did before we knew about sub_ext:)
    # wat_rx = %r{ ( (?: (?!\.rb)[^/] )* )  (?= (?:\.rb)? \z)  }x

    constantize = -> do
      rx = /(?:^|-)([a-z])/
      -> x { x.to_s.gsub( rx ) { $~[1].upcase } }
    end.call

    define_method :read_fs do
      @constants = dir_pathname.children( false ).reduce( [ ] ) do |m, pn|
        m << constantize[ pn.sub_ext( '' ).to_s ].intern
        m
      end
      nil
    end
  end
end
