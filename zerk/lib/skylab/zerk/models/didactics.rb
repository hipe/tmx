module Skylab::Zerk

  Models::Didactics = ::Struct.new(  # explained at [#055]  (currently [#br-098])
    :is_branchy,
    :description_proc,
    :description_proc_reader,
    :item_normal_tuple_stream_by,
  )

  class Models::Didactics ; class << self

    # NOTE - [tmx] only at writing VERY experimental

    def non_rootly__ defn_by, name, below_by

      _cura = Curation___.new name, below_by

      _create_by _cura do |dida_y|
        defn_by[ dida_y ]
      end
    end

    def via_participating_operator__ op

      _create_by do |dida_y|
        define_conventionaly dida_y, op
      end
    end

    def _create_by curation=nil
      o = new
      yield( DidacticYielder___.new( curation ) do |k, x|
        o[ k ] = x
      end )
      o
    end

    def define_conventionaly y, op

      # -- (not thing ding here)

      y.yield :item_normal_tuple_stream_by, op.method( :to_item_normal_tuple_stream )  # #tombstone #temporary



      # -- subject description is "curated" IFF parent is known #note-3

      cura = y.curation
      if cura

        _parent_dida = cura.below_didactics_by.call

        _desc_p = _parent_dida.description_proc_reader[ cura.name.as_lowercase_with_underscores_symbol ]

      else
        _desc_p = op.method( :describe_into )
      end

      y.yield :description_proc, _desc_p



      # -- (the others are straightforward)

      y.yield :is_branchy, op.is_branchy

      y.yield :description_proc_reader, op.description_proc_reader  # #note-3 (curator can delegate)

      NIL
    end

    undef_method :[]  # from struct, only would add confusion to use it here
    private :new
  end ; end

  class Models::Didactics

    # ==

    class DidacticYielder___ < ::Enumerator::Yielder
      def initialize cura=nil, & p
        if cura
          @curation = cura
        end
        super( & p )
      end

      attr_reader(
        :curation,
      )
    end

    # ==

    Curation___ = ::Struct.new :name, :below_didactics_by

    # ==
  end
end
