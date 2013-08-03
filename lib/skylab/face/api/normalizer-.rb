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
        Validate_arities_[ y, fld, x ]
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

    Validate_arities_ = -> y, fld, x do
      if fld.some_arity.is_polyadic
        Validate_arity_many_[ y, fld, x ]
      elsif fld.some_argument_arity.is_zero
        ( ! x ) or true == x or Detailed_monadic_niladic_errmsg_[ y, fld, x ]
      elsif x.respond_to? :each_with_index
        y << "multiple arguments were provided for #{ Fld_[ fld ] } but #{
          }only one can be accepted"  # note at [#050]
      end
      nil  # keep life simple and let the erronity be reflected in y.count
    end
    #
    Validate_arity_many_ = -> y, fld, x do
      befor = y.count
      if fld.some_argument_arity.is_zero
        x.nil? or x.respond_to? :even? or y << "strange shape for #{
        }#{ Fld_[ fld ] } - when arity is many and argument arity is #{
        } zero, the value should be an integer, had #{ Ick_[ x ] }"
      else
        x.nil? or x.respond_to? :each_with_index or y << "strange #{
        }shape for #{ Fld_[ fld ] } - when arity is many and argument #{
        }arity is one, expected array-like, had #{ Ick_[ x ] }"
      end
      ( befor == y.count && ! fld.some_arity.includes_zero && ! Some_[x] ) and
        y << "must have #{ Hack_label_[ fld.some_arity.local_normal_name ] }#{
          } #{ Fld_[ fld ] }"
      nil
    end
    #
    Detailed_monadic_niladic_errmsg_ = -> y, fld, x do
      if x.respond_to? :even?
        y << "#{ Fld_[ fld ] } was specified #{ x } times but is not #{
          }meaninful to be specified more than once"  # take a chance
      else
        y << "strange shape for #{ Fld_[ fld ] } - when arity is max one #{
          }and argument arity is zero, the only valid value value is #{
          }`true`, had #{ Ick_[ x ] }"
      end
      nil
    end

    Fld_ = -> fld do
      Hack_label_[ fld.local_normal_name ]
    end

    Ick_ = -> x do  # ( a trivial instance of [#it-001] summarization )
      if case x
      when ::NilClass, ::FalseClass, ::TrueClass, ::Numeric, ::Module ; true
      when ::String ; x.length < A_REASONABLY_SHORT_LENGTH_FOR_A_STRING_
      end then
        x.inspect
      else
        "< a #{ x.class } >"
      end
    end

    A_REASONABLY_SHORT_LENGTH_FOR_A_STRING_ = 10

    Hack_label_ = -> name_i do
      name_i.to_s.sub( /_[a-z]\z/, '' ).gsub '_', ' '
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

    Flush_method_ = -> do  # #experimental new interface for API actions ..
      # like `invoke` but takes no arguments. assume @infostream
      @y ||= ::Enumerator::Yielder.new( & @infostream.method( :puts ) )
      cy = Face::Services::Basic::Yielder::Counting.new( & @y.method( :<< ) )
      ok = Normalize_[ self, self.class::FIELDS_, cy, @param_h ]
      ok &&= execute
      ok
    end

  end
end
