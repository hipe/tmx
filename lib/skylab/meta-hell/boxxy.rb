module Skylab::MetaHell
  module Boxxy
    # Boxxy turns a module into a 'smart' module that is used as a "Box"
    # that holds and retrieves other modules, giving it behavior
    # to this end.
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
    # it might get abstractd out further into a Boxxy::Methods that is not
    # coupled ass tightly with the box implementation.)

    include MetaHell::Autoloader::Autovivifying::Recursive::ModuleMethods

    def _boxxy_init! caller_str
      _autoloader_init! caller_str
    end

    def _boxxy_init_with_no_autoloading!
      self.dir_path = false
      _autoloader_init! nil
    end

    attr_reader :boxxy_loaded

    invalid_ = -> name, f do
      o = Boxxy::InvalidNameError.new "wrong constant name #{ name }", name
      f ||= -> e { raise e }
      f[ o ]
    end

    constantize = ::Skylab::Autoloader::Inflection::FUN.constantize

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
        elsif box.dir_path && box.const_probably_loadable?( const )
          rs = box.case_insensitive_const_get const
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
    # of-concept.
    define_method :each do |& block|
      e = ::Enumerator.new do |y|    # for now we load them with "brute force"
        if ! boxxy_loaded && dir_path  # as opposed to the silly mocks we've
          @boxxy_loaded = true       # used before (we used to simply check if
          ::Dir.glob( "#{ dir_pathname }/*.rb" ).each do |path| # it was
            const = constantize[ ::Pathname.new( path ).basename.sub_ext '' ]
            case_insensitive_const_get const # an empty boxy but that got us
          end                        # into trouble were tests loaded
        end                          # explicit box items themselves, for e.g)
        constants.map(&:to_s).sort.each do |const| # We want to ensure that
          y << const_get( const, false ) # that the above issue doesn't give
        end                          # us non-deterministic sort orders
      end
      if block
        e.each { |x| block[ x ] }
      end
      e
    end


  protected

    def valid_name_rx
      @valid_name_rx ||= /\A[-_a-z]+\z/i
    end
  end
end
