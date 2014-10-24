module Skylab::Face

  module API::Params_  # read [#014] the API params narrative  #introduction

    class << self
      def [] * x_a
        via_iambic x_a
      end
      def via_iambic x_a
        # (in the spirit of [#mh-056] #contoured-fields)
        mod = (( contour = Contour_Parse__.new( x_a ) )).client_mod
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

      field_lib = Param_Field_[]
      r = field_lib.N_meta_resolver.new
      r.push nil  # [#049] - sadly necessary to get the field class for now
      r.push METAFIELD_A_A_, nil, -> x do
        Param_ = x
      end
      r.seed field_lib.meta_field_factory
      r.flush or fail "sanity"  # (result is stack size)

    end.call

    def self.enhance_client_with_param_a_and_meta_param_a client, param_a,
        meta_param_a  # fulfill [#026]
      # assume behind module mutex & `param_a` looks right structurally.

      field_lib = Param_Field_[]
      field_lib.box.via_client client do
        field_class_instance_methods -> { Param_IMs }
        meta_fields( * METAFIELD_A_A_, * meta_param_a )
        fields( * param_a )
      end

      field_lib.reflection.enhance( client ).with client

      client.include Action_IMs_

      nil
    end

    module Param_IMs

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

      def desc  # this method is in front of one higher up in the chain,
        # it mutates the parse x_a to promote strings into procs, then super
        if @x_a[ @d ].respond_to? :ascii_only?
          str = @x_a[ @d ]
          @x_a[ @d ] = -> y { y << str }
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

    class Contour_Parse__

      def initialize x_a
        @meta_param_x_a = @param_class = nil
        @params = Param_Field_[].box.new
        absrb_iambic_fully x_a ; nil
      end

      attr_reader :params

      def client_mod
        @client_mod
      end

      private
      Lib_::Fields_from_methods[ :absorber, :absrb_iambic_fully, -> do

        def client
          @client_mod = iambic_property ; nil
        end

        def meta_param
          ( @meta_param_x_a ||= [] ).push iambic_property ; nil
        end

        def param
          @param_class || bake_param_class
          param = @param_class.new iambic_property
          param.d = @d
          param.absorb_iambc_psvly @x_a
          @params.add param.local_normal_name, param
          @d = param.d
          nil
        end
      end ]

      def bake_param_class
        @param_class = @meta_param_x_a ? produce_param_class : Param_
      end

      def produce_param_class
        _Param_Field = Param_Field_[]
        param_class = nil
        r = _Param_Field.N_meta_resolver.new
        r.push nil  # [#049]
        r.push [ * METAFIELD_A_A_, * @meta_param_x_a ], nil, -> x do
          param_class = x
        end
        r.seed _Param_Field.meta_field_factory
        r.flush
        @client_mod.const_set :Param_, param_class
        Make_Include_and_or_Stow_2_Contour_IMs_[ param_class ]
        param_class
      end
    end

    Make_Include_and_or_Stow_2_Contour_IMs_ = -> client do
      im_mod = ::Module.new
      client.const_set :Autogenerated_Contour_Parse_IMs_, im_mod
      client.send :include, im_mod
      client.send :include, Param_IMs
      client.send :attr_accessor, :d
      Lib_::Fields_from_methods[
        :field_box_const, :FIELDS_FOR_PARSING__,  # FIELDS_ is taken
        :definee_module, im_mod,
        :client_class, client,
        :passive, :absorber, :absorb_iambc_psvly,
      -> do
        scn = client::FIELDS_.get_value_scanner
        while (( fld = scn.gets ))
          if fld.is_property
            Define_property_writer__[ im_mod, fld ]
          else
            Define_flag_writer__[ im_mod, fld ]
          end
        end
      end ] ; nil
    end

    Define_property_writer__ = -> mod, fld do
      m = fld.local_normal_name
      mod.send :define_method, m do
        instance_variable_set fld.as_has_predicate_ivar, true
        instance_variable_set fld.as_value_ivar, iambic_property ; nil
      end
      mod.send :private, m
    end

    Define_flag_writer__ = -> mod, fld do
      m = fld.local_normal_name
      mod.send :define_method, m do
        instance_variable_set fld.as_is_predicate_ivar, true ; nil
      end
      mod.send :private,  m
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
