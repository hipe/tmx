module Skylab::TanMan

  class Template < ::Struct.new :pathname, :string # hybrid class and namepsace
                                                   # (#pattern [#sl-109])
                                  # the stupid-simplest implementation
                                  # of templating (think mustache, but
                                  # with *only* parameter interpolation
                                  # and nothing else.)  also a sandbox for fun.

    o = { }                       # anonymous functions used all over the place

    update_members = -> members do # a function (method body) generator exp.
      -> params_h do
        a = params_h.keys - members
        if a.empty?
          params_h.each do |k, v|
            send "#{ k }=", v
          end
        else
          str = Headless::NLP::EN::Minitesimal.inflect do
            "no member#{ s a } #{ or_( a.map { |x| "'#{ x }'" } ) } in struct"
          end
          raise ::NameError.exception str
        end
      end
    end

    o[:initializer] = -> members do  # a fun stab at a generalized solution
      update_members[ members ]   # for structs that we use like this
    end

    o[:normalize_matched_parameter_name] = -> x do
      x.strip.intern
    end

    o[:parametize] = -> name do
      "{{#{ name }}}" # super duper non-robust
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

  end


  module Template::Methods        # used as both m.m's and i.m's

    define_method :parametize, & Template::FUN.parametize

  end


  module Template::ModuleMethods
    include Template::Methods

    def from_pathname pathname
      new pathname: pathname
    end

    def from_string string
      new string: string
    end

    def initializer
      Template::FUN.initializer[ members ] # pls follow the rabbit down the hole
    end

    def parameter? str, param_name
      str.include? parametize( param_name )
    end
  end


  module Template::InstanceMethods
    include Template::Methods
                                  # generate the output string! (the main thing)

    normalize = Template::FUN.normalize_matched_parameter_name

    define_method :call do |params_h|
      template_string.gsub( parameter_rx ) do
        param = normalize[ $1 ]
        if params_h.key? param
          params_h[ param ]
        else                      # else we write it back into the string (ick)?
          $~.to_s                 # for possible future chaining in a template
          parametize param        # pipeline or whatever -- *or* optionally
        end                       # we could substitue empty strings but this
      end                         # kind of thing should probably be done in
    end                           # the controller with template reflection


    formal_param_struct = ::Struct.new :surface, :normalized_name, :offset

    define_method :formal_parameters do
      ::Enumerator.new do |y|
        scn = TanMan::Services::StringScanner.new template_string
        skip_rx = /(?: (?! #{ parameter_rx.source } ) . )+/x
        while ! scn.eos?
          blank   = scn.skip skip_rx  # (change to scan if you want the match)
          surface = scn.scan parameter_rx
          if ! (blank || surface) # and it wasn't eos, then our regex must be
            fail "sanity - parse hack failure" # logic must be wrong
          end
          if surface
            normalized_name = normalize[ parameter_rx.match(surface)[1] ]
            offset = scn.pos - surface.length
            fp = formal_param_struct[ surface, normalized_name, offset ]
            y << fp
          end
        end
      end
    end

    def normalized_formal_parameter_names
      formal_parameters.map { |o| o.normalized_name }
    end

  protected

    rx = Headless::CONSTANTS::MUSTACHE_RX

    define_method( :parameter_rx ) { rx }

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


  class Template
    extend Template::ModuleMethods
    include Template::InstanceMethods

    define_method :initialize, & initializer # sorry, please watch

  end
end
