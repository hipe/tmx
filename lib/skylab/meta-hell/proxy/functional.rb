module Skylab::MetaHell

  class Proxy::Functional < ::BasicObject

    # like Ad_Hoc (see) but produces a ::Class instance rather than a
    # ::BasicObject instance. Define one as you would a ::Struct, and then
    # construct objects of it simliar to as you construct a ::Struct (but
    # passing it a ::Hash always) - this resulting object is your proxy
    # object.
    #
    # You might choose to use this rather than the Ad_Hoc variety because you
    # like the look or feel of having a statically defined nerk in your derk.

    VERBOTEN_RX = /\Ainitialize\z/  # reasons

    class << self
      alias_method :metahell_original_new, :new
    end

    me = self

    define_singleton_method :new do |*name_a, &blk|
      me == self or ::Kernel.raise "must not be subclassed directly - #{ me }"
      ::Class.new( self ).class_exec do
        member_a = self::MEMBER_A_ = name_a.freeze
        member_h = ::Hash[ member_a.map.with_index.to_a ]
        functn_h = ::Hash[ member_a.map { |x| [ x, nil ] } ]
        remain_a = 0.upto( member_a.length - 1 ).to_a

        class << self
          alias_method :new, :metahell_original_new
        end

        member_a.each do |name|
          VERBOTEN_RX =~ name and ::Kernel.raise "verboten - #{ name }"
          define_method name do |*a, &b|
            @__func_h.fetch( name )[ *a, &b ]
          end
        end

        define_method :initialize do |h|
          @__func_h = functn_h.dup
          rmn_a = remain_a.dup
          h.each do |k, v|
            rmn_a[ member_h.fetch k ] = nil
            @__func_h[ k ] = v
          end
          rmn_a.compact!
          rmn_a.length.nonzero? and ::Kernel.raise ::ArgumentError,
            "when constructing your proxy instance you must provide #{
            }(a) function(s) for - #{
            }(#{ rmn_a.map { |idx| member_a.fetch idx } * ', ' })"
          nil
        end

        blk and class_exec( & blk )

        self
      end
    end
  end
end
