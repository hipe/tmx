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
      mod.extend Boxxy::ModuleMethods
      mod._boxxy_init! caller[0]
    end
  end


  class Boxxy::NameError < ::NameError
    # We throw/pass these below. This becomes useful when it is used as a
    # metadata struct in the callbacks for name errors.

    def initialize h
      h[:message] and super( (h = h.dup).delete :message )
      h.each { |k, v| send("#{k}=", v) }
    end
  end


  class Boxxy::InvalidNameError < Boxxy::NameError
    def initialize msg, name
      super message: msg, invalid_name: name
    end
    attr_accessor :invalid_name
  end


  class Boxxy::NameNotFoundError < Boxxy::NameError
    attr_accessor :const, :module, :name, :seen
  end


  module Boxxy::ModuleMethods
    # (note that while presently this is coupled tightly with ::Module,
    # keep in mind that we might one day break parts of it out somehow,
    # possibly into an external controller or something..)

    include MetaHell::Autoloader::Autovivifying::Recursive::ModuleMethods

    def _boxxy_init! caller_str
      __boxxy_init do
        _autoloader_init! caller_str
      end
      nil
    end

    def _boxxy_init_with_no_autoloading!
      __boxxy_init do
        self.dir_path = false
        _autoloader_init! nil
      end
      nil
    end

    def __boxxy_init
      @boxxy_init_mutex ||= nil
      @boxxy_init_mutex and raise "don't init boxxy multiple times foo"
      if respond_to? :boxxy_original_constants
        raise "sanity - what's going on"
      end
      @boxxy_init_mutex = true    # initted means this stuff here
      @boxxy_is_hot = nil         # `hot` means it has hit the fs
      @boxxy_load_mutex = nil     # `loaded` means it loaded every constant
      yield
      class << self               # [#mh-019]
        alias_method :boxxy_original_constants, :constants
        alias_method :constants, :boxxy_constants
      end                         # we do this multiple times, life sucks
      nil
    end
                                  # (see `each`)
    def boxxy_constants           # (this gets swapped in for `constants`)
      @boxxy_is_hot or hit_fs     # (and feels really sketchy but seems
      @constants                  # to work ok)
    end

    fun = ::Skylab::Autoloader::Inflection::FUN

    constantize = fun.constantize

    invalid_ = -> name, f do
      o = Boxxy::InvalidNameError.new "wrong constant name #{ name }", name
      f ||= -> e { raise e }
      f[ o ]
    end

    valid_const_rx = /\A[A-Z][_a-zA-Z0-9]*\z/ # `valid_name_rx` is fallible

    define_method :const_fetch do |path_a, not_found=nil, invalid=not_found, &b|
      raise ::ArgumentError.new("can't have block + lambdas") if b && not_found
      path_a = [ path_a ] unless ::Array === path_a
      seen = [ ]
      path_a.reduce self do |box, name|
        break invalid_[ name, (invalid || b) ] if valid_name_rx !~ name.to_s
        const = constantize[ name ].intern
        break invalid_[ const, (invalid || b) ] if valid_const_rx !~ const.to_s
        rs = nil
        if box.autoloader_original_const_defined? const, false
          rs = box.const_get const, false
        elsif box.dir_path # sadly, used just as a duck-check
          if c = box.alternative_casing_match( const )
            rs = box.const_get c, false
          elsif box.const_probably_loadable?( const )
            rs = box.case_insensitive_const_get const
          end
        end
        if rs
          seen.push name
          rs
        else
          o = Boxxy::NameNotFoundError.exception message:
            "unitialized constant #{ box }::#{ const }",
            const: const, module: box, name: name, seen: seen
          f = not_found || b || -> e { raise e }
          break f[ o ]
        end
      end
    end

    def const_fetch_all *a, &b
      a.map do |const_signifier|
        const_fetch const_signifier, &b
      end
    end

    # this is SUPER #experimental OH MY GOD **SO** #experimental
    # More than #experimental, this is just a playful, jaunty little proof-
    # of-concept: If you haven't done it once already per this module, hit
    # the filesystem once to get a directory listing of all files one level
    # under dir_path. based on those files that "look like" application
    # code directories and application filenames per the regexxi below,
    # trigger the autoloader to load that file, or possibly autovivify
    # a module for the directory if thats the autoloader hack happening..
    # whether or not the above happens on this call, result in (or run
    # if `block` provided) an enumerator that enumerates over these
    # constants, yielding each of the constants themselves.
    #

    define_method :each do |& block|
      # for now we load them with "brute force" as opposed to the silly
      # mocks we've used before (we used to simply check if it was an empty
      # boxy but that got us into trouble where tests loaded explicit box
      # items themselves, for e.g) We want to ensure that this doesn't give
      # us non-deterministic sort orders.
      ea = ::Enumerator.new do |y|
        if ! @boxxy_load_mutex && dir_path
          @boxxy_load_mutex = true  # mutex lock!
          constants.each do |const|
            case_insensitive_const_get const  # MONEYSHOT
          end
        end
        constants.map(&:to_s).sort.each do |const|
          y << const_get( const, false )
        end
      end
      block ? ea.each(& block ) : ea
    end

  protected

    extname = ::Skylab::Autoloader::EXTNAME

    leaf_or_branch_rx = /\A
      (?<stem>  [a-z][a-z0-9-]* )
      (?<ext> #{ ::Regexp.escape extname } )?
    \z/x

    constantify = -> do # (tighter version for the sake of simplicity for now)
      rx = /(?:^|-)([a-z])/
      -> x { x.to_s.gsub( rx ) { $~[1].upcase } }
    end.call

    pathify = -> do # #todo **NOTE** not used but this might actually be an improvement
      rx = /(?<=[a-z])(?=[A-Z])|_|(?<=[A-Z])(?=[A-Z][a-z])/
      -> x { x.to_s.gsub( rx ){ '-' }.downcase }
    end.call

    define_method :hit_fs do    # read fs to guess what your constants are
      if dir_path && dir_pathname.exist?
        # ::Dir.glob( "#{ dir_pathname }/*.rb" ) was neat, but we want more
        existing = boxxy_original_constants          # existing!
        seen = ::Hash[ existing.map { |k| [k, true] } ]
        more = dir_pathname.children( false ).reduce( [] ) do |memo, filename|
          if leaf_or_branch_rx =~ filename.to_s
            const = constantify[ filename.sub_ext('').to_s ].intern
            seen.fetch const do |k|
              seen[k] = true # ['tree/', 'tree.rb']
              # (we here don't care if it's a branch or a leaf)
              memo << k
            end
          end
          memo
        end
        @constants = existing + more
      else
        @constants = boxxy_original_constants
      end
      @boxxy_is_hot = true
      nil
    end

    def valid_name_rx
      @valid_name_rx ||= /\A[-_a-z]+\z/i
    end
  end
end
