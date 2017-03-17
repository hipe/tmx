module Skylab::Fields

  class CommonValueStores

    # this file is ANCIENT - because it became anemic but it has so much
    # history, we re-named it to become the home for the various value
    # stores in this sidesystem. however we have left them where they are
    # for now.

    class AssociationValueReader  # 1x. here.

      # at one point it was called "bounder". produce something like a
      # [#co-004] qualified knownness, but one that produces the value
      # real-time whenever `value_x` is called (as opposed to being
      # a "cold", immutable structure).
      #
      # this is used in one file in [tm] (and also it is covered here.)

      def initialize ent, ascs
        @association_index = ascs.association_index
        @entity = ent
      end

      def association_reader_via_symbol sym

        _asc = @association_index.read_association_ sym
        ParticularAssociationValueReader___.new @entity, _asc
      end
    end

    # ==

    class ParticularAssociationValueReader___

      def initialize ent, asc

        ivar = asc.as_ivar
        @__dereference = -> do
          if ent.instance_variable_defined? ivar
            ent.instance_variable_get ivar
          else
            raise __say_not_set ivar
          end
        end
        @association = asc
      end

      def value_x
        @__dereference[]
      end

      def __say_not_set ivar
        "cannot read, is known unknown - #{ ivar }"
      end

      def name
        send( @_name ||= :__name_initially )
      end

      def __name_initially
        if @association.respond_to? :name
          @_name = :__name_classically
        else
          @__name = Common_::Name.via_lowercase_with_underscores_symbol @association.name_symbol
          @_name = :__name
        end
        send @_name
      end

      def __name_classically
        @association.name
      end

      def __name
        @__name
      end
    end

    # ==
    # ==
  end
end
# #history-B: another cleanup
# #tombsone: rewrote from ANCIENT. not-covered behavior was archived.
