module Skylab::Basic

  class String::Template

    # `Basic::String::Template` - the stupid-simplest implementation of
    # templating possible (think mustache but with *only* parameter
    # interpolation and nothing else). also some fun is creeping in.

    def self.[] get_template_string, param_h           # collapse a template
      from_string( get_template_string ).call param_h  # in one line
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
      get_template_string.gsub( parameter_rx ) do
        param = normalize $1
        if param_h.key? param
          param_h[ param ]
        else                      # else we write it back into the string
          $~.to_s                 # (ick?) for possible future chaining in a
          parametize param        # template pipeline or whatever -- *or*
        end                       # optionally we could substitue empty
      end                         # strings; but this kind of thing should
    end                           # probably be done in the the controller
                                  # with template reflection.


    alias_method :[], :call       # now we really look like a function,
                                  #   appropriately

    -> do  # `parameter_rx`
      rx = Basic::String::MUSTACHE_RX
      define_method :parameter_rx do rx end
      private :parameter_rx
    end.call

    fun = String::Template::FUN

    define_method :parametize, & fun.parametize
    private :parametize

    define_method :normalize, & fun.normalize_matched_parameter_name
    private :normalize

    Param_ = ::Struct.new :surface, :normalized_name, :offset, :_margin

    # `get_formal_parameters` - result is an enumerator that yields one ad-hoc
    # tuple with metadata for every first occurence of a parameter-looking
    # string in the template string. (it is called "get_" because currently it
    # [ reads the file and ] parses the string anew at each invocation. it is
    # future-proofing to distinguish itself from other methods that may cache
    # their results. (borrowed from a similar convention in ObjectiveC /
    # Cocoa) :[#014])

    def get_formal_parameters with_margins=false

      param_rx = parameter_rx  # it is hypothetically mutable ick
      skip_rx = /(?: (?! #{ param_rx.source } ) . )+/mx

      ::Enumerator.new do |y|
        marg = ( Margin_Engine_.new if with_margins ) ; seen_h = { }
        scn = Basic::Services::StringScanner.new get_template_string
        while ! scn.eos?
          skipped = marg ? ( scn.scan skip_rx ) : ( scn.skip skip_rx )
          surface = scn.scan param_rx
          if ! ( skipped || surface ) # and it wasn't eos, then our regex
            fail "sanity - parse hack failure"  # logic must be wrong
          end
          if surface
            norm_name = normalize param_rx.match( surface )[ 1 ]
            seen_h.fetch norm_name do
              seen_h[ norm_name ] = true
              marg and marg.take skipped
              offset = scn.pos - surface.length
              y << Param_[ surface, norm_name, offset, marg && marg.give ]
            end
          end
        end
        nil
      end
    end

    def normalized_formal_parameter_names
      get_formal_parameters.map { |o| o.normalized_name }
    end

    # `get_template_string` (private) - called "get_" because of [#014] above.

    def get_template_string
      if @string
        @string
      elsif @pathname
        if @pathname.exist?
          @pathname.read
        else
          fail "template file not found: #{ @pathname }"
        end
      else
        fail "template has no template string."
      end
    end
    private :get_template_string

    #                  ~ the section about margins ~

    # about margins ~ for some experimental attempts at SASS-like prettiness
    # in our templates, we might like to know what the "margin" is for any
    # template parameter.
    #
    # let `margin` mean the zero or more characters that occur before the
    # "surface characters" of the parameter, up to the beginning of the line
    # (excluding any leading newline from the previous line).
    #
    # any template parameter may occur multiple times in the same file,
    # however this facility only reveals the margin for the first occurence of
    # the parameter in the file. consequently a template author "needing to
    # know" the margin of a parameter that is used multiple times may need to
    # make a unique parameter representing that parameter at that occurence in
    # the file, which is probably better design anyway.
    #
    # an occurence of a parameter may have an occurence of another parameter
    # (or the same parameter) "before" it in the line (that is, between it
    # and the beginning of the line). for such occurences we say that it
    # has no margin, and result in `nil`. (we could do otherwise but it is
    # contrary to the notion (and utility) of a margin (being something fixed
    # and immutable for some context) so this is hence more poka-yoke.)

    # `first_margin_for` - see "about margins" above.

    def first_margin_for param_i
      _margin_cache_h.fetch( param_i )._margin
    end

    def _margin_cache_h
      @_margin_cache_h ||= get_formal_parameters( true ).reduce({}) do |m, fp|
        m[ fp.normalized_name ] = fp
        m
      end
    end
    private :_margin_cache_h

    Margin_Engine_ = MetaHell::Function::Class.new :give, :take
    class Margin_Engine_   # a would-be plugin to keep this logic out of the
      -> do  # `initialize`
        nl = "\n"
        define_method :initialize do
          is_fresh_line = true ; mgn = nil
          @take = -> skipped do
            mgn = nil  # allow too for the possiblity of multiple takes
                       # with no corresponding gives.
            if skipped
              rpos = skipped.rindex nl
              is_fresh_line = true if ! is_fresh_line and rpos
              if is_fresh_line
                if rpos
                  # let margin be the empty string for the relevant params
                  mgn = skipped[ rpos + 1 .. -1 ]
                else
                  mgn = skipped
                end
                is_fresh_line = false
              end
            end
            nil
          end
          @give = -> do
            x = mgn ; mgn = nil ; x
          end
        end
      end.call
    end
  end

  class String::Template

    extend String::Template::ModuleMethods

    include String::Template::InstanceMethods

    attr_reader( * ( a = %i| pathname string | ) )  # @pathanme and @string

    define_method :initialize, &
      String::Template::FUN.initialize_ivars_method_body[ a ]
  end
end
