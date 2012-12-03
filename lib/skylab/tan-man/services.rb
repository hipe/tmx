module ::Skylab::TanMan
  module Services                 # 2 different experiments in one

    extend TanMan::Boxxy

    dbg = $stderr
    fun = ::Skylab::Autoloader::Inflection::FUN
    constantize = fun.constantize
    methodify = fun.methodify
    load_method = -> const { "load_#{ methodify[ const ] }" }

    define_singleton_method :o do |const, load_const|
      define_singleton_method( load_method[ const ] ) do
        const_set const, load_const[]
      end
    end

    o :StringIO,      -> { require 'stringio' ; ::StringIO }

    o :StringScanner, -> { require 'strscan' ; ::StringScanner }

    build_service = -> pathname do
      const = constantize[ pathname.basename.to_s ]
      klass = Services.case_insensitive_const_get const # maybe triggers our
      x = klass.new               # autoloading .. we don't know here.
      x
    end

    ok_rx = /\A[-a-z]+\z/

    init = -> do                  # this gets called only once ever, and lazily
      sc = singleton_class        # it inits the whole anchor service
      sc.extend MetaHell::Let
      dir_pathname.children.each do |pathname|
        name = methodify[ pathname.basename.to_s ]
        if ok_rx =~ name
          dbg and dbg.puts "loading svc: #{ name } : #{ pathname }"
          sc.let name do          # each service is a memoized result of
            build_service[ pathname ] # this call here (see above)
          end
        else
          # skip
        end
      end
    end

    service = -> do
      init[]                      # Service.service always results in the
      service = -> { self }       # selfsame module, but call init[] once and
      self                        # lazily
    end

    define_singleton_method( :service ) { service[] }

    def self._const_missing_class
      Service_Load
    end

    o = { }

    o[:load_method] = load_method # 'export' this definition

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze
  end


  class Service_Load < MetaHell::Autoloader::Autovivifying::
                                          Recursive::ConstMissing
    extname = Autoloader::EXTNAME

    fun = TanMan::Services::FUN

    define_method :load do |*a, &b|            # Services doubles as a stdlib
      method = fun.load_method[ const ]        # loader experimentally
      if Services.respond_to? method           # this should call const_set
        Services.send method
      else
        super(*a, &b)                          # implicit argument passing [..]
      end                                      # is not supported
    end

    let :file_pathname do                      # for missing const :FooBar
      stem = pathify const                     # either load services/foo-bar.rb
      head = mod_dir_pathname.join stem        # or services/foo-bar/foo-bar.rb
      path = head.sub_ext extname
      if path.exist?
        path
      else
        head.join "#{ stem }#{ extname }"
      end
    end
  end
end
