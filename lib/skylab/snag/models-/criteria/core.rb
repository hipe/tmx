module Skylab::Snag

  class Models_::Criteria

    PERSISTED_CRITERIA_FILENAME___ = 'data-documents-/persisted-criteria'

    Brazen_ = Snag_.lib_.brazen

    Actions = ::Module.new

    class Action__ < Brazen_::Model.common_action_class  # re-opens

      Brazen_::Model.common_entity self do

      end
    end

    class Actions::Criteria_To_Stream < Action__

      edit_entity_class(

        :description, -> y do
          y << "adds to the persisted criteria collection"
        end,
        :argument_moniker, :name,
        :property, :save,

        :description, -> y do
          y << "replaces an existing persisted critera with this name"
        end,
        :argument_moniker, :name,
        :property, :edit,

        :required,
        :property, :upstream_identifier,

        :required,
        :argument_arity, :one_or_more,
        :property, :criteria

      )

      def produce_result

        ok = __resolve_any_persistence_operation
        ok &&= __resolve_criteria
        ok &&= __persist_if_necessary
        ok && __stream_via_criteria
      end

      def __resolve_any_persistence_operation

        ok = ACHIEVED_
        h = @argument_box.h_
        save_x = h[ :save ]
        edit_x = h[ :edit ]

        if save_x
          if edit_x
            handle_event_selectively.call :error, :expression, :syntax do | y |
              y << "can't simultaneously #{ par 'save' } and #{ par 'edit' }"
            end
            ok = UNABLE_
          else
            @_persistence_verb = :save
            @_persistence_arg = save_x
          end
        elsif edit_x
          @_persistence_verb = :edit
          @_persistence_arg = edit_x
        else
          @_persistence_verb = :we_are_not_persisting
        end
        ok
      end

      def __resolve_criteria

        c = Criteria_.new_via_expression(
          @argument_box.fetch( :criteria ),
          @kernel,
          & handle_event_selectively )

        if c
          @_criteria = c
          ACHIEVED_
        else
          c
        end
      end

      def __persist_if_necessary

        send :"__#{ @_persistence_verb }__criteria"
      end

      def __we_are_not_persisting__criteria
        ACHIEVED_
      end

      def __save__criteria

        @_criteria.__receive_persistence_slug_and_cetera(
          @_persistence_arg,
          @kernel.silo( :node_collection ).FS_adapter_.tmpfile_sessioner )

        a = _cc.edit(
          :via, :object,
          :unless_present,
          :add, :criteria, @_criteria,
          & handle_event_selectively )

        a && ACHIEVED_
      end

      def __stream_via_criteria

        _us_id = @argument_box.fetch :upstream_identifier
        @_criteria.to_reduced_entity_stream_via_collection_identifier _us_id
      end
    end

    class Actions::To_Criteria_Stream < Action__

      def produce_result

        _cc.to_entity_stream
      end
    end

    class Actions::Delete < Action__

      edit_entity_class(

        :desc, -> y do
          y << "(actually \"archives\")"
        end,

        :required, :property, :name
      )

      def produce_result

        _cc.edit(
          :if_present,
          :via, :slug,
          :remove, :critera, @property_box.fetch( :name ),
          & handle_event_selectively )
      end
    end

    class Action__
      def _cc
        @kernel.silo( :criteria )._cc
      end
    end

    class Silo_Daemon

      def initialize kr, _mod

        @_kr = kr
      end

      def _cc
        @__cc ||= self.class.__build_collection_via_kernel @_kr
      end

      def self.__build_collection_via_kernel kr

        Directory_as_collection_class___[].new( kr ) do | o |

          o.directory_is_assumed_to_exist = false

          o.directory_path = Snag_.dir_pathname.join(
            PERSISTED_CRITERIA_FILENAME___
          ).to_path

          o.filename_pattern = /\A[a-z0-9]+(?:[-_][a-z0-9]+)*\z/i

          o.filesystem = Snag_.lib_.system.filesystem

          o.flyweight_class = Criteria_

          yield o if block_given?

        end
      end

      def EN_domain_adapter

        @__eda ||= Criteria_::Library_::Domain_Adapter.
          new_via_kernel_and_NLP_const( @_kr, :EN )
      end
    end

    Directory_as_collection_class___ = Callback_.memoize do

      class D_as_C____ < Brazen_::Collection_Adapters::Directory_as_Collection

        class << self

          def __criteria__association_for_mutation_session
            Criteria_
          end
        end  # >>

        def has_equivalent__criteria__for_mutation_session c
          has_equivalent_item_for_mutation_session c
        end

        def description_under expag
          expag.calculate do
            'persisted criteria collection'
          end
        end

        self
      end
    end

    # -> ( criteria model )

      class << self

        def new_flyweight kr, & x_p

          o = new kr, & x_p
          o.__init_as_flyweight
          o
        end

        def new_via_expression x, kr, & x_p

          c = new kr, & x_p
          ok = c.__receive_criteria_expression x
          if ok
            c
          else
            ok
          end
        end

        def new_via__slug__ x, & x_p
          o = new :_no_kernel_
          o.__init_as_reference x
          o
        end

        def new_via__object__ x
          x
        end

        def properties
          Properties___[]
        end

        private :new
      end  # >>

      Properties___ =  Callback_.memoize do  # a sketch for front client integ.
        [
          Callback_::Actor.methodic.simple_property_class.new_via_name_symbol(
            :name
          )
        ].freeze
      end

      def initialize k, & oes_p

        @kernel = k
        @on_event_selectively = oes_p
        @ok = true
      end

      # ~ for unmarshaling a persisted

      def unmarshal & x_p

        x_p and @on_event_selectively = x_p  # meh

        s_a = ::File.read( @_path ).split SPACE_
        if s_a.length.nonzero?
          @_word_array = s_a
          _ct = _via_word_array_produce_criteria_tree
          _receive _ct, :criteria_tree
        end
      end

      # ~ for persisting

      def __receive_persistence_slug_and_cetera x, y
        _set_name_slug x
        @_tmpfile_sessioner = y
        NIL_
      end

      def express_into_under x, expad, & x_p
        send :"express_into__#{ expad.modality_const }__under", x, expad, & x_p
      end

      def express_into__Filesystem__under col_x, fs, & x_p

        Criteria_::Expression_Adapters::Filesystem[
          col_x, @_word_array, self, @_tmpfile_sessioner, fs, & x_p ]
      end

      # ~ for listing, deleting persisted critiera

      def __init_as_flyweight

        @_name_proc = -> do
          ::File.basename @_path
        end
        NIL_
      end

      def __init_as_reference slug

        _set_name_slug slug
      end

      def reinitialize_via_path_for_directory_as_collection path
        @_path = path
        NIL_
      end

      def description_under expag
        me = self
        expag.calculate do
          val me.natural_key_string
        end
      end

      def property_value_via_symbol sym
        send :"__#{ sym }__property_value"
      end

      def natural_key_string
        @_name_proc[]
      end

      def __name__property_value
        @_name_proc[]
      end

      # ~ support of above 3

      def _set_name_slug slug

        @_name_proc = -> do
          slug
        end
        NIL_
      end

      # ~

      def __receive_criteria_expression x

        _ct = if x.respond_to? :value_x
          x
        else
          @_word_array = x

          _via_word_array_produce_criteria_tree
        end

        _receive _ct, :criteria_tree
      end

      def _via_word_array_produce_criteria_tree

        @kernel.silo( :criteria ).EN_domain_adapter.
          new_criteria_tree_via_word_array(
            @_word_array, & @on_event_selectively )
      end

      def __receive_trueish__criteria_tree__ ct

        @criteria_tree =  ct

        _mc = @kernel.unbound_via_normal_identifier(
          @criteria_tree.name_x )

        remove_instance_variable :@kernel  # ick/meh

        _receive _mc, :model_class
      end

      def __receive_trueish__model_class__ mc

        @model_class = mc

        _expad = mc::Expression_Adapters::Criteria_Tree

        _receive _expad, :expression_adapter
      end

      def to_proc
        @_criteria_proc
      end

      def __receive_trueish__expression_adapter__ expad

        _lookup_p = expad.method :lookup_associated_model_

        @_criteria_proc = @criteria_tree.value_x.to_criteria_proc_under_ _lookup_p

        ACHIEVED_
      end

      def to_reduced_entity_stream_via_collection_identifier id_x

        col = @model_class.collection_module_for_criteria_resolution.

          new_via_upstream_identifier( id_x, & @on_event_selectively )

        if col
          to_reduced_entity_stream_against_collection col
        else
          col
        end
      end

      def to_reduced_entity_stream_against_collection col

        st = col.to_entity_stream( & @on_event_selectively )

        if st
          __to_reduced_entity_stream_against_entity_stream st
        else
          st
        end
      end

      def __to_reduced_entity_stream_against_entity_stream st

        p = @_criteria_proc

        st.reduce_by do | node |
          p[ node ]
        end
      end

      def _receive x, sym

        if x
          send :"__receive_trueish__#{ sym }__", x
        else
          @ok = x
          x
        end
      end

      # <-

    module Expression_Adapters
      EN = nil
      Autoloader_[ self ]
    end

    Criteria_ = self
  end
end
