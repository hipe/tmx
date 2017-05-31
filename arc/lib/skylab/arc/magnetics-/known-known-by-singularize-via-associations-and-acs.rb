module Skylab::Arc

  class Magnetics_::KnownKnownBySingularize_via_Associations_and_ACS

    # if your [ac] model has a plural assocation (i.e an "argument arity"
    # that is possibly more than one), then under [ac] (at writing) it is
    # because that association is actually defined as two associations in
    # what is described as a `singplur` pair (explained in [#029]).
    #
    # part of this arrangement is that if an an argument request specifies
    # multiple values for this plural field, then each of those values will
    # be normalized in the expected way "for free" without the model
    # author having to really think about it. here is where we implement that.

    class << self
      def call * a
        new( * a ).execute
      end
      alias_method :[], :call
    end  # >>

    def initialize sing_ca, plur_sym, plur_ca, acs
      @ACS = acs
      @plural_comp_assoc = plur_ca
      @plural_symbol = plur_sym
      @singular_comp_assoc = sing_ca
    end

    def execute

      pca = @plural_comp_assoc
      sca = @singular_comp_assoc

      pca.component_model = -> arg_st, & x_p do
        dup.___build_value arg_st, & x_p
      end

      nf = Common_::Name.via_variegated_symbol @plural_symbol
      nf.as_ivar = sca.name.as_ivar
      pca.name = nf
      pca
    end

    def ___build_value arg_st, & x_p

      x = arg_st.gets_one
      if ::Array.try_convert x
        p = __normstream_for_array x

      elsif x.respond_to? :gets
        p = __normstream_for_nonsparse_stream x

      else
        self._COVER_ME_not_array_or_stream
      end
      __money x_p, p
    end

    def __money x_p, normstream_p

        ok_value_a = []
        ok = true
        normstream_p.call do |x, d|

          _scn = Home_.lib_.fields::Argument_scanner_via_value[ x ]

          qk = Home_::Magnetics::QualifiedComponent_via_Value_and_Association.call(
            _scn,
            @singular_comp_assoc,
            @ACS,
            & x_p )

          if qk
            ok_value_a.push qk.value
          else
            ok = false
            break
          end
        end

        if ok
          Common_::KnownKnown[ ok_value_a ]
        else
          # assume the callback was called
          ok
        end
    end

    def __normstream_for_nonsparse_stream st
      self._WORKED_ONCE_but_needs_coverage_again  # #todo
      -> & y do
        d = -1
        begin
          x = st.gets
          x || break
          y[ x, ( d+=1 ) ]
          redo
        end while nil
        NIL
      end
    end

    def __normstream_for_array a
      -> & y do
        a.each_with_index( & y )
        NIL
      end
    end
  end
end
