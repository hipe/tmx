module Skylab::MetaHell

  module Boxxy

    # Boxxy is an #experiment in turning an ordinary module into a "smart"
    # module that is used a "Box" that holds, retrieves and reflection
    # on the modules it has (or might have!) to this end.
    #
    # When there is a module that is used soley as a container to hold
    # other modules, we can leverage its behavior as an ordered set,
    # and augment it with things like inflection awareness,
    # autoloading awareness, filesystem peeking of same, etc

    def self.extended mod
      if ! mod.respond_to? :const_fetch  # make it safely re-affirmable ..
        # (the above thinking could be broken out into smaller pieces..)
        mod.module_exec do
          extend Boxxy::ModuleMethods
          @tug_class = MetaHell::Autoloader::Autovivifying::Recursive::Tug
          init_boxxy caller[2]
        end
      end
      nil
    end
  end

  Boxxy::FUN = -> do

    o = { } ; fun = nil

    o[:normulate] = -> const do   # normulating, different from normifying, is
      const.to_s.gsub(/[^a-z0-9]+/i, '').downcase  # a lossier operation used in
    end                           # case- and name-function insensitive fuzzy
                                  # matching. everyone knows about normulating
    blk_rx = /([^-_a-z0-9]+)/i
    wht_rx = /\A[a-z][-_a-z0-9]*\z/i

    # experimental alternative, for when you want fuzzy loading from the
    # outside. might go into a rewrite of `const_fetch` #todo

    o[:fuzzy_const_get] = -> modul, x do
      o[:fuzzy_const_get_tuple][ modul, x ].fetch 0
    end

    o[:fuzzy_const_get_tuple] = -> mod, x do
      if blk_rx =~ x then raise ::NameError, "invalid chars - #{ $~[1] }"
      elsif wht_rx !~ x then raise ::NameError, "invalid name - #{ x }"
      else
        orig_a = mod.constants ; tgt = fun.normulate[ x ]
        idx = orig_a.index { |cnst| tgt == fun.normulate[ cnst ] }
        tuple = nil ; res = -> i do
          tuple = [ mod.const_get( i, false ), i ]
        end
        begin
          idx and break res[ orig_a.fetch idx ]
          mod.respond_to?( :dir_pathname ) && mod.dir_pathname or break res[ x ]
          try1 = MetaHell::Services::Headless::Name::FUN.constantify[ x ].intern
          tug = MetaHell::Autoloader::Autovivifying::Recursive::Tug.new try1,
            mod.dir_pathname, mod
          correction = -> do
            new_a = mod.constants - orig_a
            idx = new_a.index do |cnst|
              tgt == fun.normulate[ cnst ]
            end
            idx or raise Boxxy::NameNotFoundError.new const: x, module: mod,
              message: "coudn't find \"#{ x }\" in #{ mod }. did #{
              }you mean one of:(#{ new_a * ' ' })?", seen_a: new_a
            crct = new_a.fetch idx
            if try1 != crct
              tug.instance_variable_set :@const, crct  # confers familiarity
            end
          end
          tug.send :load, -> { correction[] }
          res[ tug.const ]
        end while nil
        tuple
      end
    end

    fun = ::Struct.new(* o.keys ).new ; o.each { |k, v| fun[k] = v }; fun.freeze
  end.call

  module Boxxy::ModuleMethods  # (note that while presently this is coupled
    # tighly with ::Module it won't necessarily remain that way - we might
    # one day break parts of it out somehow possibly into an external
    # controller or something)

    include Autoloader_::Methods  # (making Boxxy an extension of a.l is
      # convenient but not without its cost .. tracked (quietly) at [#mh-022])

    #         ~ starting at the beginning - `const_fetch` ~

    constantify = inval = valid_const_rx = resolve = nil  # scope

    define_method :const_fetch do |path_a, not_found=nil, invalid=not_found, &b|
      raise ::ArgumentError, "can't have block + lambdas" if b && not_found
      path_a = [ path_a ] unless ::Array === path_a
      seen_a = [ ]
      path_a.reduce self do |box, name|
        break inval[ name, (invalid || b) ] if valid_name_rx !~ name.to_s
        const = constantify[ name ].intern
        break inval[ const, (invalid || b) ] if valid_const_rx !~ const.to_s
        bx = resolve[ box, const ]
        if bx then bx else
          f = not_found || b || -> e { raise e }
          args = []
          if f.arity.nonzero?
            args << Boxxy::NameNotFoundError.exception(
              message: "uninitialized constant #{ box }::#{ const }",
              const: const, module: box, name: name, seen_a: seen_a
            )
          end
          break f[* args ]
        end
      end
    end

    # `names` iterate over each constant with a name function
    #  NOTE this uses flyweighting (only 1 name function).
    #  you can map(&:dupe) if you need many objects

    -> do
      fly = build_fly = nil
      define_method :names do
        fly ||= build_fly[]
        ::Enumerator.new do |y|
          constants.each do |const|
            fly.replace const
            y << fly
          end
        end
      end

      build_fly_class = nil

      build_fly = -> do
        build_fly_class[] if build_fly_class
        Boxxy::Name.new
      end

      build_fly_class = -> do
        class Boxxy::Name <
          MetaHell::Services::Headless::Name::Function::From::Constant

          def dupe
            ba = base_args
            self.class.allocate.instance_exec do
              base_init(* ba )
              self
            end
          end

          alias_method :replace, :initialize  # STFU
          public :replace

          def initialize
          end
        end
        build_fly_class = nil
      end
    end.call

  protected

    #         ~ (support for `const_fetch` in pre-order-ish) ~

    def valid_name_rx             # a hook for a custom validation rx, e.g
      @valid_name_rx ||= /\A[-_a-z]+\z/i
    end

    fun = MetaHell::Services::Headless::Name::FUN

    constantify = fun.constantify              # (used above and below)

    inval = -> name, f do
      o = Boxxy::InvalidNameError.new "wrong constant name #{ name }", name
      f ||= -> e { raise e }
      f[ o ]
    end

    valid_const_rx = /\A[A-Z][_a-zA-Z0-9]*\z/  # `valid_name_rx` is fallible

    normulate = Boxxy::FUN.normulate

    resolve = -> box, const do
      if box.const_defined? const, false
        getme = const
      else
        mini = normulate[ const ]
        m = :boxxy_original_constants
        cfunc = box.method( box.respond_to?( m ) ? m : :constants ) ; m = nil
        exist_a = cfunc.call
        cnst = exist_a.detect { |c| mini == normulate[ c ] }
        if cnst                   # then we found existing w/ a diff. casing
          getme = cnst
        elsif box.respond_to? :const_tug
          tug = box.const_tug const  # just prod the f.s with a tug
          if tug.probably_loadable?
            tug.load -> do
              exist_b = cfunc.call
              cn = ( exist_b - exist_a ).detect { |c| mini == normulate[ c ] }
              if ! cn || cn == const then getme = const else
                # then we loaded a file and the const in it is of diff. casing
                tug.instance_variable_set :@const, cn  # WONDERHACK
                getme = cn
              end
            end
            if ! getme # THEN const was probably loadable and load did not fail
              if box.const_defined? const, false  # but getme was not set in
                getme = const  # the block above SO **it autovified** omgz
              end
            end
          end
        end
      end
      box.const_get getme, false if getme
    end

    # -- that is how that story goes

    #         ~ `constants` and the social contract ~

    # `constants` - Boxxy does a thing here we will call "optimistic
    # constant inference" which is a hack that says "if you follow these
    # rules, you won't have to load a million files to know that you have
    # these million constants with these million names under this constant."
    # You can probably guess how it works. This is the part of the social
    # contract that holds this whole society together.
                                  # (see `each`)
    def boxxy_constants           # (this gets swapped in for `constants`)
      @boxxy_is_hot or hit_fs     # (and feels really sketchy but seems
      @const_a.dup                # to work ok)
    end

    public :boxxy_constants       # (yes it's nec. even w/ what we do with it)

    #         ~ (support for `boxxy_constanta` in pre-order-ish) ~

    leaf_or_branch_rx = nil  # scope

    define_method :hit_fs do
      exist_a = boxxy_original_constants       # because we care
      if @dir_pathname && @dir_pathname.exist?  # assume a.l and is initted
        # ::Dir.glob( "#{ dir_pathname }/*.rb" ) was neat, but we want more_a
        seen_h = ::Hash[ exist_a.map { |k| [ k, true ] } ]
        more_a = @dir_pathname.children( false ).reduce([]) do |memo, filename|
          if leaf_or_branch_rx =~ filename.to_s
            guess = constantify[ filename.sub_ext('').to_s ].intern
            seen_h.fetch guess do
              seen_h[guess] = true #  'tree/', 'tree.rb' => 'Tree'
                # (we here don't care if it's a branch or a leaf, also
                # casing might be wrong at this point!
              memo << guess
            end
          end
          memo
        end
        @const_a = exist_a + more_a
      else
        @const_a = exist_a
      end
      @boxxy_is_hot = true
      nil
    end

    extname = Autoloader_::EXTNAME

    leaf_or_branch_rx = /\A
      (?<stem>  [a-z][a-z0-9-]* )
      (?<ext> #{ ::Regexp.escape extname } )?
    \z/x

    #         ~ the story of `each` ~

    # (the below comment is old and not as relevant but left it b.c it's funny:)
    # this is SUPER #experimental OH MY GOD **SO** #experimental
    # More than #experimental, this is just a playful, jaunty little proof-
    # of-concept: If you haven't done it once already per this module, hit
    # the filesystem once to get a directory listing of all files one level
    # under dir_path. based on those files that "look like" application
    # code directories and application filenames per the regexxi below,
    # trigger the autoloader to load that file, or possibly autovivify
    # a module for the directory if that's the autoloader hack happening..
    # whether or not the above happens on this call, result in (or run
    # if `block` provided) an enumerator that enumerates over these
    # constants, yielding each of the constants themselves.
    #

    load_mutex_h = { }

    define_method :each do |& blk|
      ea = MetaHell::Formal::Box::Enumerator.new( -> normalized_consumer do
        load_mutex_h.fetch self do  # yes it's possible, and bad
          load_mutex_h[ self ] = true
          @const_a or constants
          @const_a.length.times do |idx|  # two passes - in one pass load each one, correcting names as you go!
            const = @const_a[ idx ]
            if ! const_defined? const, false
              tug = const_tug const  # we don't check `probably_loadable?` b.c..
              tug.load -> do
                if ! const_defined? const, false
                  mini = normulate[ const ]
                  otr = boxxy_original_constants - @const_a
                  corr = otr.detect { |c| mini == normulate[ c ] }
                  if corr
                    @const_a[ idx ] = corr   # WONDERHACK
                    tug.instance_variable_set :@const, corr
                  end # else tug will raise an exception
                end
              end
            end
          end
          load_mutex_h.delete self
        end
        @const_a.map(& :to_s ).sort.each do |const_s|  # waiting to need it
          const = const_s.intern
          normalized_consumer.yield const, const_get( const, false )
        end
      end )
      blk ? ea.each(& blk ) : ea
    end

    public :each                  # even thought it's a bold statement,
                                  # it gives us widespread compatibility

    #         ~ tiny convenience nerks (alpha. order) ~

    def const_fetch_all *a, &b
      a.map do |const_signifier|
        const_fetch const_signifier, &b
      end
    end

    public :const_fetch_all

    #       ~ abbreviations - for now it's byo-implementation ~

    def abbrev h
      @abbrev_box ||= MetaHell::Formal::Box::Open.new
      h.each do |k, v|
        @abbrev_box.add k, v
      end
      nil  # or `h` but nothing else
    end

    attr_reader :abbrev_box
    public :abbrev_box  # for now, but may change!  (please use it read only!)

  protected

    mutex = { }

    define_method :init_boxxy do |caller_str|
      mutex.fetch self do
        mutex[ self ] = true
        init_autoloader caller_str
        @boxxy_is_hot = nil       # `hot` means it has hit the fs
        @const_a = nil
        class << self
          alias_method :boxxy_original_constants, :constants  # [#mh-019]
          alias_method :constants, :boxxy_constants
        end
      end
      nil
    end
  end

  class Boxxy::NameError < ::NameError

    # We throw/pass these below. This becomes useful when it is used as a
    # metadata struct in the callbacks for name errors.

    def initialize h
      super( (h = h.dup).delete :message ) if h[:message]
      h.each { |k, v| send "#{ k }=", v }
    end
  end

  class Boxxy::InvalidNameError < Boxxy::NameError

    attr_accessor :invalid_name

    def initialize msg, name
      super message: msg, invalid_name: name
    end
  end

  class Boxxy::NameNotFoundError < Boxxy::NameError
    attr_accessor :const, :module, :name, :seen_a
  end
end
