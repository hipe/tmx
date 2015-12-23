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
    end

    def initialize h
      @_h = h
    end

    def symbols sym

      @_indexed ||= _index
      @_symbols_under_ad_hod_classification[ sym ]
    end

    def write_ivars me, x_a

      @_indexed ||= _index

      flag = @_is_flag
      ivar = @_ivar_for
      seen = {}
      st = Callback_::Polymorphic_Stream.via_array x_a

      begin
        k = st.gets_one
        seen[ k ] = true
        me.instance_variable_set ivar[k], ( flag[k] ? true : st.gets_one )
      end until st.no_unparsed_exists

      @_a.each do | k_ |
        seen[ k_ ] and next
        me.instance_variable_set ivar[ k_ ], nil
      end

      NIL_
    end

    def _index

      flag_h = {}
      ivar_h = {}

      op_h = {}
      op_h[ :flag ] = -> k do
        flag_h[ k ] = true
      end

      custom = -> kk, kk_ do

        cust_h = ::Hash.new { |h, k| h[k] = [] }
        @_symbols_under_ad_hod_classification = cust_h.method :fetch
        custom = -> k, k_ do
          cust_h[ k_ ].push k ; nil
        end
        custom[ kk, kk_ ]
      end

      names = []

      @_h.each_pair do |k, x|
        a = [ * x ]
        names.push k
        ivar_h[ k ] = nil
        flag_h[ k ] = nil
        a.each do | k_ |
          p = op_h[ k_ ]
          if p
            p[ k ]
          else
            custom[ k, k_ ]
          end
        end
      end

      @_a = names

      @_is_flag = flag_h.method :fetch

      @_ivar_for = -> k do
        ivar = ivar_h.fetch k
        if ! ivar
          ivar = :"@#{ k }"
          ivar_h[ k ] = ivar
        end
        ivar
      end

      ACHIEVED_
    end
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

  can_be_more_than_one = nil
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
      if can_be_more_than_one[ prp.argument_arity ]
        true
      elsif can_be_more_than_one[ prp.parameter_arity ]
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

  can_be_more_than_one = {
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
  UNABLE_ = false
end
