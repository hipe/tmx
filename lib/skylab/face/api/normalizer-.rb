module Skylab::Face

  module API::Normalizer_  # experiment - can you make an extension
    # module where you get to cherry-pick which instance methods you want?

    def self.enhance_client_class client
      puff = If_not_defined_.curry[ client ]
      puff[ :public, :normalize, Normalize_method_ ]
      puff[ :public, :field_normalize, Field_normalize_method_ ]
      puff[ :public, :field_value_notify, Field_value_notify_method_ ]
    end

    If_not_defined_ = -> client, pub_priv, m, proc_p do
      if ! ( client.method_defined? m or client.private_method_defined? m )
        client.instance_exec do
          define_method m, & proc_p
          :private == pub_priv and private m
        end
      end
    end

    Normalize_ = -> obj, field_box, y, par_h do
      # mutates par_h [#fa-019] [#bl-013] [#sl-116]
      miss_a = nil ; r = false ; before = y.count
      fld_val_notify = M_or_p_[ obj, :field_value_notify, Field_value_notify_ ]
      fld_normalize = M_or_p_[ obj, :field_normalize, Field_normalize_ ]
      field_box.each do |i, fld|
        x = ( par_h.delete i if par_h and par_h.key? i )
        fld_val_notify[ fld, x ]
        if fld.has_normalizer || fld.has_default  # yes after

          x = fld_normalize[ y, fld, x ]
        end
        fld.is_required && x.nil? and ( miss_a ||= [] ) << fld
      end
      begin
        Some_[ par_h ] and break( y << "undeclared #{
          }parameter(s) - (#{ par_h.keys * ', ' }) for #{ obj.class }. #{
          }(declare it/them with `params` macro?)" )
        miss_a and break( y << "missing required parameter(s) - (#{
          }#{ miss_a.map( & :local_normal_name ) * ', ' }) #{
          }for #{ obj.class }." )
        y.count > before and break
        r = true
      end while nil
      r
    end
    M_or_p_ = -> obj, meth_i, proc_p do
      obj.respond_to?( meth_i ) ? obj.method( meth_i ) : proc_p.curry[ obj ]
    end

    Normalize_method_ = -> y, par_h do
      Normalize_[ self, field_box, y, par_h ]
    end

    Field_value_notify_method_ = -> fld, x do
      ivar = fld.as_host_ivar
      instance_variable_defined? ivar and !
        instance_variable_get( ivar ).nil? and
          fail "sanity - ivar collision: #{ ivar }"
      instance_variable_set ivar, x
      nil
    end

    Functionalize_meth_proc_ = -> p do
      case p.arity
      when 2 ; -> o, a, b    { o.instance_exec a, b, &p }
      when 3 ; -> o, a, b, c { o.instance_exec a, b, c, &p }
      else   ; fail "unhack or pro-hack me"
      end      # sadly this is the cleanest way to preserve absolute arity
    end        # which is necessary for curry to work without coupling

    Field_value_notify_ = Functionalize_meth_proc_[Field_value_notify_method_]

    Field_normalize_method_ = -> y, fld, x do # result per [#034]. write
      # notices to `y`. `x` is the input and then result value of field `fld`.

      ivar = fld.as_host_ivar

      fld.has_default && x.nil? and
        x = instance_variable_set( ivar,
          instance_exec( & fld.default_value ) )  # always a proc

      if fld.has_normalizer
        true == (( p = fld.normalizer_value )) and
          p = method( :"normalize_#{ fld.local_normal_name }" )

        x = instance_exec y, x, -> normalized_x do
          instance_variable_set ivar, normalized_x
          nil
        end, & p
      end

      x  # the system wants to know the particular nil-ish-ness of x
    end

    Field_normalize_ = Functionalize_meth_proc_[ Field_normalize_method_ ]

  end
end
