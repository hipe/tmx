require 'skylab/callback'

module Skylab::Fields

  # (a new file created after dissolution of [m-h] - has little history. see [#001])

  class << self

    def from_methods * i_a, & defn_p
      Home_::From_Methods___.call_via_arglist i_a, & defn_p
    end

    def lib_
      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  class Parameters  # :[#013].

    class << self
      alias_method :[], :new
      private :new
    end  # >>

    def initialize h
      @_is_parsed = nil
      @_indexes = nil
      @_unparsed_h = h
    end

    def init o, x_a
      @_is_parsed || _parse
      Parse___.new( o, x_a, self ).execute
    end

    def to_required_symbol_stream
      h = optionals_hash
      st = Callback_::Stream.via_nonsparse_array @_h.keys
      if h
        st.reduce_by do |sym|
          ! h[ sym ]
        end
      else
        st
      end
    end

    def optionals_hash
      @_is_parsed || _parse
      if @_indexes
        @_indexes.optionals
      end
    end

    def symbols * sym
      if sym.length.zero?
        if @_is_parsed
          @_h.keys
        else
          @_unparsed_h.keys
        end
      else
        ___fetch_particular( * sym )
      end
    end

    def ___fetch_particular sym
      @_is_parsed || _parse
      @_custom_indexes.fetch sym
    end

    def [] k
      @_h.fetch k
    end

    def _parse

      @_is_parsed = true

      op_h = PARAM_INTERP___
      h = {}

      _h = remove_instance_variable :@_unparsed_h
      _h.each_pair do | k, x |
        o = Param___.new k, self
        h[ k ] = o
        if x
          if ::Array.try_convert x
            st = Callback_::Polymorphic_Stream.via_array x
            o._st = st
            begin
              _p = op_h[ st.gets_one ]
              o.instance_exec( & _p )
            end until st.no_unparsed_exists
          else
            _p = op_h[ x ]
            o.instance_exec( & _p )
          end
        end
        o.close
      end

      @_h = h
      @build_param_getser = __build_param_getser_builder
      NIL_
    end

    def __index_under_custom par, sym
      ( ( @_custom_indexes ||= {} )[ sym ] ||= [] ).push par.name_symbol ; nil
    end

    def __index_under par, sym
      _idx = ( @_indexes ||= Indexes___.new )
      ( _idx[ sym ] ||= {} )[ par.name_symbol ] = true
      NIL_
    end

    Indexes___ = ::Struct.new :optionals

    def __build_param_getser_builder

      h = @_h

      orig = -> parse do
        st = parse.st
        -> do
          h.fetch st.gets_one
        end
      end

      if @_indexes
        opts = @_indexes.optionals
      end

      if opts
        -> parse do
          gets_one = orig[ parse ]
          pool = opts.dup
          parse.normalize = Nilify___[ pool ]
          -> do
            par = gets_one[]
            pool.delete par.name_symbol
            par
          end
        end
      else
        orig
      end
    end

    attr_reader(
      :build_param_getser,
    )
  end

  Nilify___ = -> pool do
    -> do
      pool.keys.each do |k|
        ivar = @pars[ k ].as_ivar
        if ! @o.instance_variable_defined? ivar
          @o.instance_variable_set ivar, nil
        end
      end
      NIL_
    end
  end

  # ~ parse

  class Parse___

    def initialize o, x_a, pars
      @normalize = nil
      @o = o
      @pars = pars
      @st = Callback_::Polymorphic_Stream.via_array x_a
    end

    def execute
      st = @st
      gets_one_param = @pars.build_param_getser[ self ]
      until st.no_unparsed_exists
        _par = gets_one_param[]
        Assignment___.new( @o, @st, _par, @pars ).execute
      end
      if @normalize
        instance_exec( & @normalize )
      end
      NIL_
    end

    attr_accessor(
      :normalize,
    )

    attr_reader(
      :st,
    )
  end

  # ~ the meta-parameters

  Value_Proxy__ = ::Struct.new :gets_one
  fake_yes = Value_Proxy__.new true

  flag = -> do
    @x = true ; NIL_
  end

  flag_of = -> k do
    -> do
      @pars[ k ][ @o, fake_yes, @pars ]
      NIL_
    end
  end

  kn_kn = -> do
    _x = @st.gets_one
    @x = Callback_::Known_Known[ _x ]
    NIL_
  end

  singular_of = -> k do
    -> do
      _st = Value_Proxy__.new [ @st.gets_one ]
      @pars[ k ][ @o, _st, @pars ]
      NIL_
    end
  end

  PARAM_INTERP___ = {
    flag: -> do
      @stack[ 1 ] = flag
    end,
    flag_of: -> do
      @stack[ 0 ] = flag_of[ @_st.gets_one ]
    end,
    known_known: -> do
      @stack[ 0 ] = kn_kn
    end,
    optional: -> do
      @_index.__index_under self, :optionals ; nil
    end,
    singular_of: -> do
      @stack[ 0 ] = singular_of[ @_st.gets_one ]
    end
  }.tap do |h|
    h.default_proc = -> _, k { -> { @_index.__index_under_custom self, k } }
  end

  # ~

  class Assignment___

    # the way the "stack" works is that when you get to the bottom of it,
    # IFF @x is set you assign that into the ivar of the client instance

    def initialize o, st, par, pars
      @o = o
      @par = par
      @pars = pars
      @st = st
    end

    def execute
      stack = @par.stack
      d = stack.length
      if d.zero?
        @x = @st.gets_one
      else
        begin
          d -= 1
          _p = stack.fetch d
          instance_exec( & _p )
          if d.zero?
            break
          end
          redo
        end while nil
      end

      if instance_variable_defined? :@x
        @o.instance_variable_set @par.as_ivar, @x
      end
      NIL_
    end
  end

  class Param___

    def initialize k, indxr

      @_index = indxr
      @stack = []
      @_st = nil
      @name_symbol = k
    end

    def [] o, st, pars
      Assignment___.new( o, st, self, pars ).execute
      NIL_
    end

    attr_writer(
      :_st,
    )

    def __become_singular_of sym
      $stderr.puts "SOMETHING"
    end

    def close
      @stack.compact!
      remove_instance_variable :@_index
      remove_instance_variable :@_st ; nil
    end

    def as_ivar
      @___as_ivar ||= :"@#{ @name_symbol }"
    end

    attr_reader(
      :name_symbol,
      :stack,
    )
  end

  # -- the external functions experiment ..

  # ~ description & name

  N_lines = -> d, expag, prp do  # #curry-friendly

    p = prp.description_proc
    if p
      if d
        N_lines_via_proc[ d, expag, p ]
      else
        expag.calculate [], & p
      end
    else
      self._EASY_BUT_DESIGN_AND_COVER_ME
    end
  end

  N_lines_via_proc = -> d, expag, p do

    o = Home_.lib_.basic::String::N_Lines.session

    o.number_of_lines = d  # nil OK

    o.expression_agent = expag

    o.description_proc = p

    o.execute
  end

  Has_description = -> prp do
    prp.description_proc
  end

  # ~ normalization-related (including parameter arity derivatives)

  Has_default = -> prp do
    prp.default_proc
  end

  includes_zero = nil

  Is_effectively_optional = -> prp do
    if prp.default_proc
      true
    else
      ! Is_required[ prp ]
    end
  end

  Is_required = -> prp do
    if includes_zero[ prp.parameter_arity ]
      false
    else
      # (hi.)
      if includes_zero[ prp.argument_arity ]
        :zero == prp.argument_arity  # the "required flag"
      else
        true
      end
    end
  end

  # ~ argument arity derivations

  Takes_many_arguments = -> prp do
    if Takes_argument[ prp ]
      if Can_be_more_than_one[ prp.argument_arity ]
        true
      elsif Can_be_more_than_one[ prp.parameter_arity ]
        true  # hi.
      end
    end
  end

  Argument_is_optional = -> prp do  # assume "takes argument"

    # an argument being optional is different than a parameter being optional.
    # avoid this nastiness if you have a choice! more at [#br]#self-wormhole-1

    includes_zero[ prp.argument_arity ]
  end

  Takes_argument = -> prp do
    Can_be_more_than_zero[ prp.argument_arity ]
  end

  # ~ support

  includes_zero = {
    zero: true,
    zero_or_one: true,
    zero_or_more: true,
  }

  Can_be_more_than_zero = {
    zero_or_one: true,
    one: true,
    zero_or_more: true,
    one_or_more: true,
  }

  Can_be_more_than_one = {
    zero_or_more: true,
    one_or_more: true,
  }

  # --

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Human = sidesys[ :Human ]
    Plugin = sidesys[ :Plugin ]

  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  CLI = nil  # for host
  EMPTY_A_ = []
  EMPTY_S_ = ""
  Home_ = self
  NIL_ = nil
  SPACE_ = ' '
  UNABLE_ = false
end
