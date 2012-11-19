module Skylab::TanMan
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

    def const_fetch path_a, name_error=nil, invalid_name_error=nil, &both
      both and name_error || invalid_name_error and
        raise ::ArgumentError.exception("can't have both block and lambda args")
      path_a = [path_a] unless ::Array === path_a
      seen = []
      path_a.reduce self do |box, mixed_name|
        if valid_name_rx !~ mixed_name.to_s
          invalid_name_error ||= name_error || both || ->( e ) { raise e }
          return invalid_name_error[ Boxxy::InvalidNameError.exception(
            message: "wrong constant name #{ mixed_name }",
            invalid_name: mixed_name
          ) ]
        end
        const = Inflection::FUN.constantize[ mixed_name ].intern
        if ! box.autoloader_original_const_defined?(const, false) and
           ! box.const_probably_loadable? const
        then
          name_error ||= both || ->( e ) { raise e }
          return name_error[ Boxxy::NameNotFoundError.exception(
            message: "unitialized constant #{ box }::#{ const }",
            const: const,
            module: box,
            name: mixed_name,
            seen: seen
          ) ]
        end
        seen.push mixed_name
        box.case_insensitive_const_get const
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
    def each
      constantize = Autoloader::Inflection::FUN.constantize
      e = ::Enumerator.new do |y|
        if constants.empty? # for now, load them with brute force (a), (b) iff
          ::Dir.glob( "#{dir_pathname}/*.rb" ).each do |path| # empty
            const = constantize[ ::Pathname.new( path ).basename.sub_ext('') ]
            case_insensitive_const_get const
          end
        end
        constants.each do |const|
          y << const_get( const, false )
        end
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
