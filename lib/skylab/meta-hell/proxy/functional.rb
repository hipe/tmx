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

    class << self
      alias_method :metahell_original_new, :new
    end

    me = self

    define_singleton_method :new do |*names|
      me == self or fail "do not subclass #{ me } directly"
      struct = ::Struct.new(* names )
      kls = ::Class.new self
      kls.class_exec do
        class << self
          alias_method :new, :metahell_original_new
        end
        names.each do |name|
          define_method name do |*a, &b|
            @functions[ name ][ *a, &b ]
          end
        end
        len = names.length
        define_method :initialize do |h|
          @functions = struct.new
          h.each { |k, v| @functions[k] = v }
          len == h.length or ::Object.send :raise, ::ArgumentError, "your #{
            }proxy must define (#{ ( struct.members - h.keys ) * ', ' })"
        end
      end
      kls
    end
  end
end
