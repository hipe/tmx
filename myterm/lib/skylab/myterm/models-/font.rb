module Skylab::MyTerm

  class Models_::Font

    # a compound component with state and operations.

    # -- Construction methods

    class << self

      def interpret_compound_component p, _asc, acs
        p[ new.__init_as_entity acs ]
      end

      def __new_flyweight k
        new.__init_as_flyweight k
      end

      private :new
    end  # >>

    # -- Initializers

    def __init_as_entity ke_source

      @_do_express_skipped = true  # eew - avoid repetition here

      @kernel_ = ke_source.kernel_

      @path = nil

      self
    end

    # -- experimental flyweightism (not clean)

    def __init_as_flyweight ke
      @kernel_ = ke
      self
    end

    def __reinit path
      @path = path ; self
    end

    def initialize_dup _
      remove_instance_variable :@kernel_
      freeze
    end

    # -- Expressive event & modality hook-ins/hook-outs

    def describe_into_under y, _  # for #during #milestone-5 (or not..)

      y << "set font, list available fonts"
    end

    def express_into_under y, expag
      me = self
      expag.calculate do  # (hi.)
        y << me.path
      end
    end

    def description_under expag  # for expressive events..

      s = ::File.basename @path
      expag.calculate do
        val s
      end
    end

    def express_of_via_into_under y, _expag
      -> me do
        y << me.path
      end
    end

    # -- Components

    def __path__component_association

      -> st, & pp do

        path = st.current_token

        _o = _build_new_collection_controller( & pp )

        x = _o.lookup_font_path__ :set, path

        if x
          st.advance_one
          Callback_::Known_Known[ x ]
        else
          x
        end
      end
    end

    def __list__component_operation

      yield :description, -> y do
        y << 'hackishly list the known fonts'
      end

      -> & pp do

        _o = _build_new_collection_controller( & pp )

        _st = _o.to_expressing_path_stream_

        fly = self.class.__new_flyweight @kernel_

        _st.map_by do |path|

          fly.__reinit path
        end
      end
    end

    def _build_new_collection_controller & pp
      Here_::Collection_Controller___.new @kernel_, & pp
    end

    attr_reader(
      :path,
    )

    Here_ = self
  end
end
# #pending-rename: b.d
# #tombstone: contextualization
# #tombstone: contextualization (again)
