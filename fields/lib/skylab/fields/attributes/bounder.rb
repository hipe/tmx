module Skylab::Fields

  class Attributes

    class Bounder  # ANCIENT

      class << self

        def _call sess

          _attrs = sess.class::ATTRIBUTES
          new sess, _attrs
        end

        alias_method :[], :_call
        alias_method :call, :_call
        remove_method :_call

        private :new
      end

      def initialize sess, attrs
        @attributes = attrs
        @session = sess
      end

      def lookup k

        _attr = @attributes.attribute k

        Bound___.new @session, _attr
      end

      class Bound___  # much like a writable [#ca-004] qkn

        # (note we scrapped TONS of blah blah because it wasn't covered..)

        def initialize sess, attr

          ivar = attr.as_ivar
          @_read = -> do
            if sess.instance_variable_defined? ivar
              sess.instance_variable_get ivar
            else
              raise __say_not_set ivar
            end
          end
        end

        def value_x
          @_read[]
        end

        def __say_not_set ivar
          "cannot read, is known unknown - #{ ivar }"
        end
      end
    end
  end
end
# #tombsone: rewrote from ANCIENT. not-covered behavior was archived.
