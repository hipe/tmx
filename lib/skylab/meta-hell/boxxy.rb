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

    invalid_ = -> name, f do
      f ||= -> e { raise e }
      o = Boxxy::InvalidNameError.new "wrong constant name #{ name }", name
      f[ o ]
    end

    constantize = ::Skylab::Autoloader::Inflection::FUN.constantize

    define_method :const_fetch do |path_a, not_found=nil, invalid=not_found, &b|
      b && not_found and raise ::ArgumentError.new "can't have block + lambdas"
      result = nil ; ::Array === path_a or path_a = [path_a]
      begin
        seen = [ ]
        r = path_a.reduce self do |box, name|
          if valid_name_rx !~ name.to_s
            result = invalid_[ name, (invalid || b) ]
            break
          end
          const = constantize[ name ].intern
          if /\A[A-Z][_a-zA-Z0-9]*\z/ !~ const.to_s # above is fallible
            result = invalid_[ const, (invalid || b) ]
            break
          end
          if box.autoloader_original_const_defined? const, false or
             box.const_probably_loadable? const
          then
            seen.push name
            box.case_insensitive_const_get const
          else
            f = not_found || b || -> e { raise e }
            o = Boxxy::NameNotFoundError.exception(
              message: "unitialized constant #{ box }::#{ const }",
              const: const, module: box, name: name, seen: seen
            )
            result = f[ o ]
            break
          end
        end
        r and result = r
      end while false
      result
    end

    def const_fetch_all *a, &b
      a.map do |const_signifier|
        const_fetch const_signifier, &b
      end
    end

    # this is SUPER #experimental OH MY GOD **SO** #experimental
    # More than #experimental, this is just a playful, jaunty little proof-
    # of-concept.
    define_method :each do
      e = ::Enumerator.new do |y|    # for now we load them with "brute force"
        if ! (@boxxy_loaded ||= nil) # as opposed to the silly mocks we've
          @boxxy_loaded = true       # used before (we used to simply check if
          ::Dir.glob( "#{dir_pathname}/*.rb" ).each do |path| # it was
            const = constantize[ ::Pathname.new( path ).basename.sub_ext('') ]
            case_insensitive_const_get const # an empty boxy but that got us
          end                        # into trouble were tests loaded
        end                          # explicit box items themselves, for e.g)
        constants.map(&:to_s).sort.each do |const| # We want to ensure that
          y << const_get( const, false ) # that the above issue doesn't give
        end                          # us non-deterministic sort orders
      end
      if block_given?
        e.each { |o| yield o }
      end
      e
    end


  protected

    def valid_name_rx
      @valid_name_rx ||= /\A[-_a-z]+\z/i
    end
  end
end
