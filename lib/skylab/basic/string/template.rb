module Skylab::Basic

  class String::Template

    # `Basic::String::Template` - the stupid-simplest implementation of
    # templating possible (think mustache but with *only* parameter
    # interpolation and nothing else). also a sandbox for fun.

    def self.[] template_string, param_h           # collapse a template
      from_string( template_string ).call param_h  # in one line
    end

    o = { }                       # anonymous functions used all over the place

    # `initialize_ivars_method_body` - generates a function to be a method body

    o[:initialize_ivars_method_body] = -> member_a do
      ivar_h    = ::Hash[ member_a.map { |i| [ i, :"@#{ i }" ] } ]
      default_h = ::Hash[ member_a.map { |i| [ i, nil ] } ]
      -> param_h do
        a = param_h.keys - member_a
        if a.empty?
          dflt_h = default_h.dup
          param_h.each do |k, v|
            dflt_h.delete k
            instance_variable_set ivar_h.fetch( k ), v
          end
          dflt_h.each do |k, v|
            instance_variable_set ivar_h.fetch( k ), v
          end
        else
          raise ::NameError, Services::Headless::NLP::EN::Minitesimal::FUN.
              inflect[ -> do
            "no member#{ s a } #{ or_( a.map { |x| "'#{ x }'" } ) } in struct"
          end ]
        end
      end
    end

    o[:normalize_matched_parameter_name] = -> x do
      x.strip.intern
    end

    o[:parametize] = -> name do
      "{{#{ name }}}" # super duper non-robust
    end

    FUN = ::Struct.new( * o.keys ).new( * o.values ).freeze

  end  # re-opens below [#sl-109]

  module String::Template::ModuleMethods

    def from_path path
      new pathname: ( path ? ::Pathname.new( path.to_s ) : path )
    end

    def from_string string
      new string: string
    end

    def parameter? str, param_name
      str.include? parametize( param_name )
    end

    define_method :parametize, & String::Template::FUN.parametize
    private :parametize

  end

  module String::Template::InstanceMethods

    def call param_h
      template_string.gsub( parameter_rx ) do
        param = normalize $1
        if param_h.key? param
          param_h[ param ]
        else                      # else we write it back into the string (ick)?
          $~.to_s                 # for possible future chaining in a template
          parametize param        # pipeline or whatever -- *or* optionally
        end                       # we could substitue empty strings but this
      end                         # kind of thing should probably be done in
    end                           # the controller with template reflection

    -> do  # `parameter_rx`
      rx = Basic::String::MUSTACHE_RX
      define_method :parameter_rx do rx end
      private :parameter_rx
    end.call

    define_method :parametize, & String::Template::FUN.parametize
    private :parametize

    define_method :normalize, &
      String::Template::FUN.normalize_matched_parameter_name
    private :normalize

    alias_method :[], :call       # alias the above defined method.  careful!
                                  # now we look like a function yay.

    Param_ = ::Struct.new :surface, :normalized_name, :offset

    def formal_parameters
      ::Enumerator.new do |y|
        scn = Basic::Services::StringScanner.new template_string
        skip_rx = /(?: (?! #{ parameter_rx.source } ) . )+/x
        while ! scn.eos?
          blank   = scn.skip skip_rx  # (change to scan if you want the match)
          surface = scn.scan parameter_rx
          if ! (blank || surface) # and it wasn't eos, then our regex must be
            fail "sanity - parse hack failure" # logic must be wrong
          end
          if surface
            normalized_name = normalize parameter_rx.match(surface)[1]
            offset = scn.pos - surface.length
            y << Param_[ surface, normalized_name, offset ]
          end
        end
      end
    end

    def normalized_formal_parameter_names
      formal_parameters.map { |o| o.normalized_name }
    end

  protected

    def template_string
      if string
        string
      elsif pathname
        if pathname.exist?
          pathname.read
        else
          fail "template file not found: #{pathname}"
        end
      else
        fail "template has no template string."
      end
    end
  end

  class String::Template

    extend String::Template::ModuleMethods

    include String::Template::InstanceMethods

    attr_reader( * ( a = %i| pathname string | ) )

    define_method :initialize, &
      String::Template::FUN.initialize_ivars_method_body[ a ]
  end
end
