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

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  class Attributes < ::Module

    class << self
      alias_method :[], :new
      alias_method :call, :new
      undef_method :new
    end  # >>

    def initialize h
      @attribute_class = nil
      @_h = h
      @meta_attributes = nil
    end

    # --

    def define_meta_attribute * x_a, & x_p
      Here_::DSL.new( self, x_a, & x_p ).execute
    end

    attr_writer(
      :attribute_class,
      :meta_attributes,
    )

    def attribute_class__
      @attribute_class
    end

    def meta_attributes__
      @meta_attributes
    end

    # --

    def init o, x_a, & x_p
      _index.init__ o, x_a, & x_p
    end

    def normalize_session o, & x_p
      _index.normalize_session__ o, & x_p
    end

    def define_methods mod
      _index.define_methods__ mod
    end

    # --

    def symbols * sym
      if sym.length.zero?
        @_h.keys
      else
        _index.lookup_particular__( * sym )
      end
    end

    def to_defined_attribute_stream
      _index.to_defined_attribute_stream__
    end

    def attribute k
      _index.lookup_attribute_ k
    end

    def _index
      @___index ||= ___build_index
    end

    alias_method :index_, :_index

    def ___build_index
      Here_::Lib::Index_of_Definition___.new( @_h,
        ( @meta_attributes || Here_::MetaAttributes ),
        ( @attribute_class || Here_::Lib::DefinedAttribute ),
      )
    end

    module Actor

      class << self

        def _call cls, h=nil

          if h
            attrs = Here_[ h ]
            cls.const_set :ATTRIBUTES, attrs
          else
            cls.const_set :ATTRIBUTES, nil
          end

          cls.extend Module_Methods___
          cls.include InstanceMethods
          attrs  # as covered..
        end

        alias_method :[], :_call
        alias_method :call, :_call
      end  # >>

      module Module_Methods___

        # ~ ways to call your actor (pursuant to [#bs-028.A] name conventions)

        def with * x_a, & x_p  # 1
          call_via_iambic x_a, & x_p
        end

        def call_via_iambic x_a, & x_p
          sess = new_via_iambic x_a, & x_p
          if sess
            sess.execute
          else
            sess
          end
        end

        def new_with * x_a, & x_p
          new_via_iambic x_a, & x_p
        end

        def new_via_iambic x_a, & x_p

          _st = Callback_::Polymorphic_Stream.via_array x_a
          New_via__[ :process_polymorphic_stream_fully, _st, self, & x_p ]
        end

        def new_via_polymorphic_stream st, & x_p
          New_via__[ :process_polymorphic_stream_fully, st, self, & x_p ]
        end

        def new_via_polymorphic_stream_passively st, & x_p
          New_via__[ :process_polymorphic_stream_passively, st, self, & x_p ]
        end

        def polymorphic_stream_via_iambic x_a
          Callback_::Polymorphic_Stream.via_array x_a
        end
      end

      New_via__ = -> m, st, cls, & x_p do  # near #open [#026]

        sess = cls.send :new, & x_p  # actors reasonably expect the handler here [br]

        kp = sess.send m, st, & x_p  # but this here is for all non-actors

        if kp
          sess
        else
          kp
        end
      end

      module InstanceMethods

        def new_with * x_a, & x_p
          x_p and self._DESIGN_ME
          otr = dup
          kp = otr.send :process_iambic_fully, x_a
          if kp
            otr
          else
            self._COVER_ME
          end
        end

      private

        def process_iambic_fully x_a
          process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
        end

        def polymorphic_stream_via_iambic x_a
          Callback_::Polymorphic_Stream.via_array x_a
        end

        def process_polymorphic_stream_fully st, & x_p
          kp = process_polymorphic_stream_passively st, & x_p
          if kp
            if st.no_unparsed_exists
              kp
            elsif x_p
              self._K
            else
              when_after_process_iambic_fully_stream_has_content st
            end
          else
            kp
          end
        end

        def process_polymorphic_stream_passively st, & x_p

          cls = self.class
          if cls.const_defined? :ATTRIBUTES, false
            _atrs = cls.const_get :ATTRIBUTES
          end

          Here_::Lib::Process_polymorphic_stream_passively_.call(
            st, self, _atrs,
            polymorphic_writer_method_name_passive_lookup_proc,
            & x_p )
        end

        def gets_one_polymorphic_value  # #public-API #hook-in
          @_polymorphic_upstream_.gets_one
        end

        def polymorphic_upstream  # n.c
          @_polymorphic_upstream_
        end

        def polymorphic_writer_method_name_passive_lookup_proc  # #public-API #hook-in
          Here_::Lib::Writer_method_reader___[ self.class ]
        end

        def when_after_process_iambic_fully_stream_has_content stream  # :+#public-API
          _ev = Home_::Events::Extra.via_strange stream.current_token
          receive_extra_values_event _ev
        end  # :#spot-1

        def receive_extra_values_event ev  # :+#public-API (name) :+#hook-in
          raise ev.to_exception
        end
      end
    end

    # --

    Classic_writer_method_ = -> name_symbol do
      :"#{ name_symbol }="
    end

    # --

    Autoloader_[ self ]

    ARG_STREAM_IVAR_ = :@_polymorphic_upstream_
    Here_ = self
  end

  class SimplifiedName

    def initialize k
      @cache_ = {}
      yield self
      @name_symbol = k
      freeze
    end

    def as_ivar= x
      @cache_[ :_as_ivar_ ] = x
    end

    def as_ivar
      @cache_.fetch :_as_ivar_ do
        x = :"@#{ @name_symbol }"
        @cache_[ :_as_ivar_ ] = x
        x
      end
    end

    def name  # for [#br-035] (wormhole). also covered here
      @cache_.fetch :_name_ do
        x = Callback_::Name.via_variegated_symbol @name_symbol
        @cache_[ :_name_ ] = x
        x
      end
    end

    attr_reader :name_symbol
  end

  class Argument_stream_via_value  # :[#019] (2x similar)

    class << self
      alias_method :[], :new
      private :new
    end  # >>

    def initialize x
      @_done = false
      @_kn = Callback_::Known_Known[ x ]
    end

    def gets_one
      x = current_token
      advance_one
      x
    end

    def current_token
      @_kn.value_x
    end

    def advance_one
      remove_instance_variable :@_kn
      @_done = true ; nil
    end

    def unparsed_exists
      ! @_done
    end

    def no_unparsed_exists
      @_done
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
  KEEP_PARSING_ = true
  Lazy_ = Callback_::Lazy
  MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
  NIL_ = nil
  NOTHING_ = nil
  SPACE_ = ' '
  UNABLE_ = false
end
