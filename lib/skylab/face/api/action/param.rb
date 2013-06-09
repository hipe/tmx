module Skylab::Face

  module API::Action::Param

    # this whole node if for experimenting in the automatic creation of a set
    # of meta-fields that can be recognized by the entity library. tag your
    # fields with these metafields and we can try to make magic happen for you
    #
    # [#fa-014] (for now under the entity node)

    METAFIELDS_ = [

      [ :arity, :property ],  # [#fa-024]

      [ :desc, :property ],  # [#fa-030]

      [ :normalizer, :property ],  # [#fa-021]

      [ :default, :property ],  # [#fa-033]

      # (trailing comma above is intentional and syntactically valid, but still
      # feels really weird to do without justifying it with this long comment)
    ].tap { |a| a.freeze.each( & :freeze ) }

    # `self.[]` - enhance the API::Action class with this facet.
    # fulfill [#fa-026]. assumes it is behind a module mutex.
    # assumes `param_a` looks right structurally.

    def self.[] host_mod, param_a, meta_param_a
      Services::Basic::Field::Box.enhance host_mod do
        field_class_instance_methods -> { API::Action::Param::Field_IMs_ }
        meta_fields( * API::Action::Param::METAFIELDS_, * meta_param_a )
        fields( * param_a )
      end
      Services::Basic::Field::Reflection.enhance( host_mod ).with host_mod
      host_mod.send :include, API::Action::Param::InstanceMethods
      nil
    end
  end

  module API::Action::Param::Field_IMs_

    # isomorph the idea of required-ness from the arity - resolve a
    # range-like into a boolean [#fa-024]

    def is_required
      if has_arity
        ! arity.includes_zero
      else
        true
      end
    end

    def arity
      if @has_arity
        @arity ||= Services::Headless::Arity[ @arity_value ]
      end
    end
  end

  module API::Action::Param::InstanceMethods

    def has_param_facet
      true
    end
    # public. fulfill [#fa-027].

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

    -> do

      truefunc = -> _ { true }
      symfunc = -> i do
        -> bf do
          bf.field[ i ]
        end
      end
      define_method :unpack_params do |ix, *a|
        a.unshift ix ; res_a = ::Array.new( len = a.length )
        len.times do |idx|
          res_a[ idx ] = { } # sneak this in here
          v = a[idx]
          if ::Symbol == v.class  # meh
            a[idx] = symfunc[ v ]
          elsif true == v
            a[idx] = truefunc
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
    end.call
  end
end
