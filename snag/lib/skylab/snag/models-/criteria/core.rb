module Skylab::Snag

  class Models_::Criteria

    PERSISTED_CRITERIA_FILENAME___ = 'data-documents-/persisted-criteria'

    Actions = ::Module.new

    # (as model starts #here)

    CriteriaAction__ = ::Class.new

    class Actions::IssuesViaCriteria < CriteriaAction__

      def definition ; [

        :property, :save,
        :description, -> y do
          y << "adds to the persisted criteria collection"
        end,
        :argument_moniker, :name,

        :property, :edit,
        :description, -> y do
          y << "replaces an existing persisted critera with this name"
        end,
        :argument_moniker, :name,

        :required, :property, :upstream_reference,

        :required, :property, :criteria,  # #tombstone-A: used to be `glob`

      ] end

      def initialize
        super
        @edit = @save = nil  # #[#026]
      end

      def execute
        ok = __resolve_any_persistence_operation
        ok &&= __resolve_criteria
        ok &&= __persist_if_necessary
        __stream_via_criteria if ok  # #[#007.C]
      end

      # --

      def __stream_via_criteria

        _us_id = remove_instance_variable :@upstream_reference

        @_criteria.to_reduced_entity_stream_via_collection_identifier _us_id
      end

      # --

      def __persist_if_necessary

        send :"__#{ @_persistence_verb }__criteria"
      end

      def __we_are_not_persisting__criteria
        ACHIEVED_
      end

      def __save__criteria

        _sessioner = @_invocation_resources_.node_collection_filesystem_adapter.tmpfile_sessioner

        @_criteria.__receive_persistence_slug_and_tmpfile_sessioner(
          @_persistence_arg,
          _sessioner,
        )

        _o = _criterion_collection.edit(
          :via, :object,
          :assuming, :not, :exists,
          :add, :criteria, @_criteria,
          & _listener_ )

        _o && ACHIEVED_
      end

      # --

      def __resolve_criteria

        _a = remove_instance_variable :@criteria
        _ = Here_.via_expression _a, @_invocation_resources_, & _listener_
        _store :@_criteria, _
      end

      # --

      def __resolve_any_persistence_operation
        if @save
          if @edit
            __when_save_and_edit
          else
            __when_save_only
          end
        elsif @edit
          __when_edit_only
        else
          __when_not_persisting
        end
      end

      def __when_save_and_edit
        _listener_.call :error, :expression, :syntax do |y|
          y << "can't simultaneously #{ par 'save' } and #{ par 'edit' }"
        end
        UNABLE_
      end

      def __when_save_only
        remove_instance_variable :@edit
        @_persistence_verb = :save
        @_persistence_arg = remove_instance_variable :@save ; true
      end

      def __when_edit_only
        remove_instance_variable :@save
        @_persistence_verb = :edit
        @_persistence_arg = remove_instance_variable :@edit ; true
      end

      def __when_not_persisting
        remove_instance_variable :@edit
        remove_instance_variable :@save
        @_persistence_verb = :we_are_not_persisting ; true
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    class Actions::To_Criteria_Stream < CriteriaAction__

      def execute

        _criterion_collection.to_entity_stream
      end
    end

    class Actions::Delete < CriteriaAction__

      def definition ; [

        :branch_description, -> y do
          y << "(actually \"archives\")"
        end,

        :required, :property, :name
      ] end

      def execute

        _criterion_collection.edit(
          :assuming, :exists,
          :via, :slug,
          :remove, :critera, @name,
          & _listener_ )
      end
    end

    class CriteriaResources

      class << self
        alias_method :via_invocation_resources__, :new
        undef_method :new
      end  # >>

      def initialize invo_rsx
        @_invocation_resources = invo_rsx
      end

      def __the_criterion_collection
        @___criterion_collection ||= __build_criterion_collection
      end

      def __build_criterion_collection
        CriterionCollection___.define do |o|
          o.invocation_resources = @_invocation_resources
        end
      end

      def EN_domain_adapter
        @__eda ||= __EN_domain_adapter
      end

      def __EN_domain_adapter
        Here_::Library_::DomainAdapter.via_NLP_const_and_invocation_resources__(
          :EN, @_invocation_resources )
      end
    end

    # - as model (:#here)

      class << self

        def new_flyweight invo_rsx, & x_p

          o = new invo_rsx, & x_p
          o.__init_as_flyweight
          o
        end

        def via_expression x, invo_rsx, & x_p

          c = new invo_rsx, & x_p
          _ok = c.__receive_criteria_expression x
          _ok && c
        end

        def via__slug__ x
          o = new
          o.__init_as_reference x
          o
        end

        def via__object__ x
          x
        end

        def properties
          Properties___[]
        end

        private :new
      end  # >>

      Properties___ =  Common_.memoize do  # a sketch for front client integ.
        [
          Home_.lib_.fields::SimplifiedName.new( :name )
        ].freeze
      end

      def initialize invo_rsx=nil, & p

        if invo_rsx
          invo_rsx.HELLO_INVO_RSX
          @_invocation_resources = invo_rsx
        end

        @_listener = p

        @ok = true
      end

      # ~ for unmarshaling a persisted

      def unmarshal & x_p

        x_p and @_listener = x_p  # meh

        s_a = ::File.read( @_path ).split SPACE_
        if s_a.length.nonzero?
          @_word_array = s_a
          _ct = _via_word_array_produce_criteria_tree
          _receive _ct, :criteria_tree
        end
      end

      # ~ for persisting

      def __receive_persistence_slug_and_tmpfile_sessioner s, o
        _set_name_slug s
        @_tmpfile_sessioner = o ; nil
      end

      def express_into_under x, expad, & x_p
        send :"express_into__#{ expad.modality_const }__under", x, expad, & x_p
      end

      def express_into__Filesystem__under col_x, fs, & x_p

        Here_::ExpressionAdapters::Filesystem.call(
          col_x, @_word_array, self, @_tmpfile_sessioner, fs, & x_p )
      end

      # ~ for listing, deleting persisted critiera

      def __init_as_flyweight

        @_receive_path = :__receive_path_normally
        @_slug = :__slug_normally ; nil
      end

      def __init_as_reference slug

        _set_name_slug slug
      end

      def __reinitialize_as_flyweight path
        send @_receive_path, path
      end

      def __receive_path_normally path
        @_path = path ; self
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
        send @_slug
      end

      def __name__property_value
        send @_slug
      end

      # -- slug and derivatives

      def _set_name_slug slug
        @_receive_path = :_NO__not_a_flyweight__
        @_slug = :__slug_via_value
        @__slug = slug ; nil
      end

      def __slug_via_value
        @__slug
      end

      def __slug_normally
        ::File.basename @_path
      end

      def normal_symbol  # (because flyweight, don't memoize)
        _slug = send @_slug
        _slug.gsub( DASH_, UNDERSCORE_ ).intern
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

        @_invocation_resources.criteria_resources.EN_domain_adapter.
          new_criteria_tree_via_word_array @_word_array, & @_listener
      end

      def __receive_trueish__criteria_tree__ ct

        sym_a = ct.name_x

        1 == sym_a.length || self._HAVE_FUN__deep_names_you_dont_want_this__

        _normal_symbol = Common_::Name.via_const_symbol( sym_a.fetch 0 ).
          as_lowercase_with_underscores_symbol  # NodeCollection -> node_collection etc

        _ob = @_invocation_resources.microservice_operator_branch_

        _loadable_reference = _ob.dereference _normal_symbol

        _business_module = _loadable_reference.dereference_loadable_reference

        @criteria_tree = ct

        _receive _business_module, :business_module
      end

      def __receive_trueish__business_module__ bm

        @business_module = bm

        _expad = bm::ExpressionAdapters::CriteriaTree

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

        col = @business_module.collection_module_for_criteria_resolution.

          via_upstream_reference id_x, @_invocation_resources, & @_listener

        col and to_reduced_entity_stream_against_collection col
      end

      def to_reduced_entity_stream_against_collection col

        st = col.to_entity_stream( & @_listener )

        st and __to_reduced_entity_stream_against_entity_stream st
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

    # -

    # ==

    class CriteriaAction__

      def initialize
        extend ActionRelatedMethods_
        @_invocation_resources_ = yield
        init_action_ @_invocation_resources_
      end

      def _criterion_collection

        _crx = @_invocation_resources_.criteria_resources
        _cc = _crx.__the_criterion_collection
        _cc  # hi. #todo
      end
    end

    # ==

    class CriterionCollection___ < Common_::SimpleModel  # #testpoint

      # the remote implementor models a directory as a customizable [ac]
      # collection-like component, one to which files can be added and
      # removed from using standard [ac] operations.
      #
      # we leverage this implementation through composition (not inheritence)
      # (but we used to just inherit) and make it so the items that are
      # added/removed are criterions (not files).

      def initialize
        yield self
        @directory_path ||= ::File.join Home_.dir_path, PERSISTED_CRITERIA_FILENAME___
        __flush_self_to_init_implementor
      end

      attr_writer(
        :directory_path,
        :invocation_resources,
      )

      def __flush_self_to_init_implementor

        invo_rsx = remove_instance_variable :@invocation_resources

        # ~ experimentally we're keeping flyweighting around even though it's out of fashion

        flyweight = nil
        main = -> path do
          flyweight.__reinitialize_as_flyweight path
        end
        p = -> path do
          flyweight = Here_.new_flyweight invo_rsx
          p = main
          p[ path ]
        end

        # ~

        _fs = invo_rsx.node_collection_filesystem_adapter.filesystem  # or whatever

        _path = remove_instance_variable :@directory_path

        _OB = Home_.lib_.system_lib::Filesystem::Directory::OperatorBranch_via_Directory

        @_imp = _OB.define do |o|

          o.loadable_reference_via_path_by = -> path do
            p[ path ]
          end

          o.startingpoint_path = _path

          o.filename_pattern = /\A[a-z0-9]+(?:[-_][a-z0-9]+)*\z/i

          o.directory_is_assumed_to_exist = false

          o.descriptive_name_symbol = :persisted_criteria_collection

          o.filesystem_for_globbing = _fs
        end

        NIL
      end

      # (conventional sections per [#ac-005])

      # -- Human exposures

      def edit * x_a, & p

        _ACS = ACS_[]
        _ACS.edit x_a, self, & ( -> _ { p } )  # "pp"
      end

      # -- support for above

      [ :__add__component,
        :__remove__component,
        :expect_component_not__exists__,
        :expect_component__exists__,
      ].each do |m|
        define_method m do |qk, & p_or_pp|
          @_imp.send m, qk, & p_or_pp
        end
      end

      def to_entity_stream
        @_imp.to_loadable_reference_stream
      end

      # -- Components

      def __criteria__component_association

        yield :can, :add, :remove

        Here_
      end
    end

    # ==

    module ExpressionAdapters
      EN = nil
      Autoloader_[ self ]
    end

    DASH_ = '-'
    Here_ = self

    # ==
  end
end
# :#tombstone-A.2 (temporary): xx
# #tombstone-A (temporary): criteria used to be glob but it's inconvenient
#   until [#ze-023] ("glob") is perfect
