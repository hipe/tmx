module ::Skylab::TanMan
  module Services                 # 2 different experiments in one
                                  # being #watched [#mh-011]

    extend MetaHell::Boxxy

    dbg = nil #  $stderr
    fun = ::Skylab::Autoloader::Inflection::FUN
    methodify = fun.methodify
    load_method = -> const { "load_#{ methodify[ const ] }" }

    define_singleton_method :o do |const, load_const|
      define_singleton_method( load_method[ const ] ) do
        const_set const, load_const[]
      end
    end

    o :OptionParser,  -> { require 'optparse' ; ::OptionParser }

    o :PP,            -> { require 'pp'       ; ::PP }

    o :Open3,         -> { require 'open3'    ; ::Open3 }

    o :StringIO,      -> { require 'stringio' ; ::StringIO }

    o :StringScanner, -> { require 'strscan'  ; ::StringScanner }

    build_service = -> pathname do
      klass = Services.const_fetch pathname.basename.sub_ext('').to_s # BOXXY!!
      x = klass.new               # autoloading .. we don't know here.
      x
    end

    extname = Autoloader::EXTNAME
    ok_rx = /\A[-a-z]+\z/         # ..

    init = -> do                  # this gets called only once ever, and lazily
      sc = singleton_class        # it inits the whole anchor service
      sc.extend MetaHell::Let
      dir_pathname.children.each do |pathname|
        o = pathname.basename
        if extname == o.extname
          o = o.sub_ext ''
        end
        o = o.to_s
        if ok_rx =~ o
          name = methodify[ o.to_s ]
          dbg and dbg.puts "loading svc: #{ name } : #{ pathname }"
          sc.let name do          # each service is a memoized result of
            build_service[ pathname ] # this call here (see above)
          end
        else
          # skip
        end
      end
    end

    services = -> do
      init[]                      # Service.services always results in the
      services = -> { self }       # selfsame module, but call init[] once and
      self                        # lazily
    end

    define_singleton_method( :services ) { services[] }

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

    define_method :load do |f=nil|             # Services doubles as a stdlib
      method = fun.load_method[ const ]        # loader experimentally
      if Services.respond_to? method           # this should call const_set
        Services.send method
      else
        super f                                # implicit argument passing [..]
      end                                      # is not supported
    end

    def load_file( * )
      super
      if @tanman_hack
        o = mod.const_get const, false         # NASTY
        o.dir_pathname = o.dir_pathname.dirname
      end
      nil
    end

    let :file_pathname do                      # for missing const :FooBar
      stem = pathify const                     # either load services/foo-bar.rb
      head = mod_dir_pathname.join stem        # or services/foo-bar/foo-bar.rb
      path = head.sub_ext extname
      res = nil
      if path.exist?
        @tanman_hack = false
        res = path
      else
        @tanman_hack = true
        res = head.join "#{ stem }#{ extname }"
      end
      res
    end
  end
end
