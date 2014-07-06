module Skylab::Face

  module API::Params_  # read [#014] the API params narrative  #introduction

    class << self
      def [] * x_a
        via_iambic x_a
      end
      def via_iambic x_a
        # (in the spirit of [#mh-056] #contoured-fields)
        mod = (( contour = Contour_Parse_.new( * x_a ) )).client_mod
        mod.const_set :FIELDS_, contour.params  # gotta #comport with fields lib
        nil
      end
    end

    METAFIELD_A_A_ = [

      [ :arity, :property ],  # [#024]

      [ :argument_arity, :property ],  # #experimental

      [ :desc, :property ],  # [#030]

      [ :normalizer, :property ],  # [#021]

      # hack a specialized sub "class" of normalizer - the 'set' macro:
      [ :set, :property, :hook, :mutate, -> fld do  # #experimental
        fld.instance_exec do
          @has_normalizer = true ; set_x = @set_value
          @normalizer_value = -> y, x, _ do
            set_x.include? x or begin
              y << ( @expression_agent.instance_exec do
                "invalid #{ lbl fld.local_normal_name } value #{
                  }#{ ick x }. expecting #{ or_ set_x }"
              end )
            end  # (always result in received value - additional notices e.g
            x  # about this as a missing required field sound redundant)
          end
        end
      end ],

      [ :default, :property ],  # [#033]

      [ :single_letter, :property ],

      [ :argument_string, :property ]

    ].tap { |a| a.freeze.each( & :freeze ) }

    Param_Field_ = Lib_::Field_class

    -> do

      _Param_Field = Param_Field_[]
      r = _Param_Field::N_Meta_Resolver_.new
      r.push nil  # [#049] - sadly necessary to get the field class for now
      r.push METAFIELD_A_A_, nil, -> x do
        Param_ = x
      end
      r.seed _Param_Field::Meta_Field_Factory_
      r.flush or fail "sanity"  # (result is stack size)

    end.call

    def self.enhance_client_with_param_a_and_meta_param_a client, param_a,
        meta_param_a  # fulfill [#026]
      # assume behind module mutex & `param_a` looks right structurally.

      _Param_Field = Param_Field_[]
      _Param_Field::Box.enhance client do
        field_class_instance_methods -> { Param_IMs_ }
        meta_fields( * METAFIELD_A_A_, * meta_param_a )
        fields( * param_a )
      end

      _Param_Field::Reflection.enhance( client ).with client

      client.send :include, Action_IMs_

      nil
    end

    module Param_IMs_

      def is_required *a
        # isomorph the idea of required-ness from the arity [#024]
        ! some_arity.includes_zero
      end

      def some_arity
        if has_arity
          Parameter_Arities_.fetch @arity_value
        else
          Parameter_Arities_.fetch :one
        end
      end

      def some_argument_arity
        if has_argument_arity
          Argument_Arities_.fetch @argument_arity_value
        else
          Argument_Arities_.fetch :one
        end
      end

    private

      def desc a  # "override" one that is higher up on the chain to let this
        if (( str = a.first )).respond_to? :ascii_only?  # sugar through
          a[ 0 ] = -> y { y << str }
        end
        super
      end
    end

    p = -> space, x do
      _a = space.each.map { |ar| "'#{ ar.local_name_function.local_normal }'" }
      _or = Lib_::EN_oxford_or[ _a ]
      _for = Lib_::Name_module_moniker[ space ]
      _msg = "'#{ x }' is not a recognized arity of the #{ _for } - #{
        }did you mean #{ _or }?"
      raise ::NameError, _msg
    end

    Parameter_Arities_ = Lib_::Arity_space_create[ p, -> do
      self::ZERO_OR_ONE = new 0, 1
      self::ZERO_OR_MORE = new 0, nil
      self::ONE = new 1, 1
      self::ONE_OR_MORE = new 1, nil
    end ]

    Argument_Arities_ = Lib_::Arity_space_create[ p, -> do
      self::ZERO = new 0, 0
      self::ZERO_OR_MORE = new 0, nil
      self::ONE = new 1, 1
    end ]

    class Contour_Parse_

      def initialize *a
        @meta_param_x_a = @param_class = nil
        @params = Param_Field_[]::Box.new
        _FIXME_absrb( * a ) ; nil
      end

      attr_reader :params

      def client_mod
        @client_mod
      end

      private
      Lib_::Fields_from_methods[ -> do

        def client a
          @client_mod = a.shift
          nil
        end

        def meta_param a
          ( @meta_param_x_a ||= [ ] ) << a.shift
          nil
        end

        def param a
          @param_class || bake_param_class
          param = @param_class.new( a.fetch 0 ) ; a.shift
          param.absorb_iambic_fully a
          @params.add param.local_normal_name, param
          nil
        end
      end ]

      def bake_param_class
        @param_class = @meta_param_x_a ? produce_param_class : Param_
      end

      def produce_param_class
        _Param_Field = Param_Field_[]
        param_class = nil
        r = _Param_Field::N_Meta_Resolver_.new
        r.push nil  # [#049]
        r.push [ * METAFIELD_A_A_, * @meta_param_x_a ], nil, -> x do
          param_class = x
        end
        r.seed _Param_Field::Meta_Field_Factory_
        r.flush
        @client_mod.const_set :Param_, param_class
        Make_Include_and_or_Stow_2_Contour_IMs_[ param_class ]
        param_class
      end
    end

    Make_Include_and_or_Stow_2_Contour_IMs_ = -> client do
      im_mod = ::Module.new
      client.class_exec do
        const_set :Autogenerated_Contour_Parse_IMs_, im_mod
        include im_mod
        include Param_IMs_
      end
      Contour_[ client::FIELDS_, im_mod ]
      nil
    end

    Contour_ = -> field_box, im_mod do
      im_mod.module_exec do
        Lib_::Fields_from_methods[ -> do
          field_box.values.each do |fld|
            if fld.is_property
              Contour_with_property_[ im_mod, fld ]
            else
              Contour_with_flag_[ im_mod, fld ]
            end
          end
        end ]
      end
      nil
    end

    Contour_with_property_ = -> im_mod, fld do
      m = fld.local_normal_name
      im_mod.send :define_method, m do |a|
        instance_variable_set fld.as_has_predicate_ivar, true
        instance_variable_set fld.as_value_ivar, a.fetch( 0 ) ; a.shift
        nil
      end
      im_mod.send :private, m
    end

    Contour_with_flag_ = -> im_mod, fld do
      m = fld.local_normal_name
      im_mod.send :define_method, m do |_|
        instance_variable_set fld.as_is_predicate_ivar, true
        nil
      end
      im_mod.send :private,  m
    end

    Make_Include_and_or_Stow_2_Contour_IMs_[ Param_ ]

    module Action_IMs_

      def has_param_facet  # fulfill [#027].
        true
      end

      # [#014]:#the-unpack-params-method

      def unpack_params ix, *a
        a.unshift ix ; res_a = ::Array.new( len = a.length )
        len.times do |idx|
          res_a[ idx ] = { }  # sneak this in here
          v = a[idx]
          if v.respond_to? :id2name
            a[ idx ] = Get_aref_proc_[ v ]
          elsif true == v
            a[ idx ] = MONADIC_TRUTH_
          end
        end
        fields_bound_to_ivars.each do |bf|
          len.times do |idx|
            if a[ idx ].call bf
              res_a[ idx ][ bf.field.local_normal_name ] = bf.value
              break
            end
          end
        end
        res_a
      end

      Get_aref_proc_ = -> i do  # (`aref` as in ruby source - hash.c)
        -> bound_field do
          bound_field.field[ i ]
        end
      end
    end
  end
end
