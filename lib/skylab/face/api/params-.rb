module Skylab::Face

  module API::Params_

    # this whole node is for an #experiment with the automatic creation of a
    # set of meta-fields that can be recognized by the entity library. tag
    # your fields with these metafields and we can try to make magic happen
    # for you. but note it is only the beginning. within e.g a given action
    # class you can create arbitrary new meta-fields to describe your fields
    # with, and use them however you want in that action :[#fa-014].

    METAFIELD_A_A_ = [

      [ :arity, :property ],  # [#fa-024]

      [ :argument_arity, :property ],  # #experimental

      [ :desc, :property ],  # [#fa-030]

      [ :normalizer, :property ],  # [#fa-021]

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

      [ :default, :property ],  # [#fa-033]

      [ :single_letter, :property ],

      [ :argument_string, :property ]

    ].tap { |a| a.freeze.each( & :freeze ) }

    -> do

      fld = (( Field = Services::Basic::Field ))
      r = fld::N_Meta_Resolver_.new
      r.push nil  # [#049] - sadly necessary to get the field class for now
      r.push METAFIELD_A_A_, nil, -> x do
        Param_ = x
      end
      r.seed fld::Meta_Field_Factory_
      r.flush or fail "sanity"  # (result is stack size)

    end.call

    def self.enhance_client_with_param_a_and_meta_param_a client, param_a,
        meta_param_a  # fulfill [#fa-026]
      # assume behind module mutex & `param_a` looks right structurally.

      Field::Box.enhance client do
        field_class_instance_methods -> { Param_IMs_ }
        meta_fields( * METAFIELD_A_A_, * meta_param_a )
        fields( * param_a )
      end

      Field::Reflection.enhance( client ).with client

      client.send :include, Action_IMs_

      nil
    end

    module Param_IMs_

      def is_required *a
        # isomorph the idea of required-ness from the arity [#fa-024]
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

    Parameter_Arities_ = Face::Services::Headless::Arity::Space.create do
      self::ZERO_OR_ONE = new 0, 1
      self::ZERO_OR_MORE = new 0, nil
      self::ONE = new 1, 1
      self::ONE_OR_MORE = new 1, nil
    end

    Argument_Arities_ = Face::Services::Headless::Arity::Space.create do
      self::ZERO = new 0, 0
      self::ONE = new 1, 1
    end

    def self.[] * x_a
      # (in the spirit of MetaHell::FUN::Fields_::Countoured_)
      mod = (( contour = Contour_Parse_.new( * x_a ) )).client_mod
      mod.const_set :FIELDS_, contour.params  # gotta compat with fields lib
      nil
    end

    class Contour_Parse_

      def initialize *a
        @meta_param_x_a = @param_class = nil
        @params = Field::Box.new
        absorb( * a )
      end

      attr_reader :params

      def client_mod
        @client_mod
      end

      private
      MetaHell::FUN::Fields_::From_.methods do

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
          param.absorb_notify a
          @params.add param.local_normal_name, param
          nil
        end
      end

      def bake_param_class
        @param_class = @meta_param_x_a ? produce_param_class : Param_
      end

      def produce_param_class
        param_class = nil
        r = Field::N_Meta_Resolver_.new
        r.push nil  # [#049]
        r.push [ * METAFIELD_A_A_, * @meta_param_x_a ], nil, -> x do
          param_class = x
        end
        r.seed Field::Meta_Field_Factory_
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
        MetaHell::FUN::Fields_::From_.methods do
          field_box.each do |fld|
            if fld.is_property
              Contour_with_property_[ im_mod, fld ]
            else
              Contour_with_flag_[ im_mod, fld ]
            end
          end
        end
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

      def has_param_facet  # fulfill [#fa-027].
        true
      end

    # `unpack_params` (what it was formerly is described in [#fa-012]) result
    # is a tuple (fixed length array) of the same number as the number of
    # your arguments. each value of the tuple will be a hash whose each key
    # and value correspond to one of the bound parameters. which pair goes in
    # which hash is determined as follows: each of your arguments is resolved
    # into a function. the function will be run against each of the parameters
    # in order (of the functions). any first such call whose result is true-
    # ish, the search is short-circuited. whatever position the function
    # had in your provided order of functions, the resulting key-value pair
    # will be inserted into the hash of the corresponding position in the
    # result tuple WHEW! the number of result pairs is guaranteed to be less
    # that or equal to the number of bound parameters: it is possible that
    # bound parameters fail all of the functions, in which case they are not
    # reflected in the result. above we said `resolved into a function` - if
    # you pass a ::Symbol, it will send that symbol using :[] to each field,
    # the true-ish-ness of that result determines whether it is a match. if
    # you pass `true`, the true function will be used (matches everything),
    # which is useful only at the end as a catch-all base case.
    # #todo wtf test-case documentation hello

      def unpack_params ix, *a
        a.unshift ix ; res_a = ::Array.new( len = a.length )
        len.times do |idx|
          res_a[ idx ] = { }  # sneak this in here
          v = a[idx]
          if v.respond_to? :id2name
            a[ idx ] = Get_aref_proc_[ v ]
          elsif true == v
            a[ idx ] = MetaHell::MONADIC_TRUTH_
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
