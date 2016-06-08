module Skylab::Snag

  class Models_::Node

    module Criteria  # ersatz class as proxy

      class << self

        def new s_a

          Home_::Models_::Criteria.new_via_expression(
            s_a,
            Home_.application_kernel_ )
        end
      end  # >>
    end

    # -- Construction methods

    class << self

      # (tenets in [#ac-002])

      def interpret_component st, & o_p_p  # #Tenet5..

        ACS_[].interpret st, new, & o_p_p
      end

      def edit_entity * x_a, & o_p_p  # #Tenet2

        ACS_[].create x_a, new, & o_p_p
      end

      def collection_module_for_criteria_resolution

        Home_::Models_::Node_Collection
      end

      def new_via_body x  # #Tenet7A1

        new nil, x
      end

      def new_via__identifier__ x  # #Tenet7

        new x
      end

      private :new  # #Tenet1
    end  # >>

    # -- Initializers

    def initialize id_o=nil, body=nil

      @body = body

      @_did_change = false

      @_extended_content_adapter = if body
        body.extended_content_adapter_
      end

      if id_o
        @ID = id_o
      end
    end

    def reinitialize id_o

      @ID = id_o
      NIL_
    end

    def reinitialize_copy_ src

      @body.reinitialize_copy_ src.body
      @ID.reinitialize_copy_ src.ID

      NIL_
    end

    def initialize_copy src

      @body = src.body.dup
      @ID = src.ID.dup

      NIL_
    end

    # -- Operations (sort of)

    def prepend_string s, & oes_p

      edit :prepend, :string, s, & oes_p
    end

    def append_string s, & oes_p

      edit :append, :string, s, & oes_p
    end

    def prepend_tag symbol, & oes_p

      edit :prepend, :tag, symbol, & oes_p
    end

    def append_tag symbol, & oes_p

      edit :append, :tag, symbol, & oes_p
    end

    def remove_tag symbol, & oes_p

      edit :remove, :tag, symbol, & oes_p
    end

    def edit * x_a, & oes_p

      # this is a boundary between cold and hot [#ac-006]

      _oes_p_p = -> _ do
        oes_p
      end

      ACS_[].edit x_a, self, & _oes_p_p
    end

    # -- Components

    def __extended_content__component_association

      # model only (used by reflecting for CLI)

      EC___
    end

    def __identifier__component_association

      yield :can, :set

      yield :stored_in_ivar, :@ID

      Home_::Models_::Node_Identifier
    end

    def __message__component_association

      yield :can, :append

      Mixed_Message___
    end

    def __string__component_association

      yield :can, :prepend, :append

      Home_::Models::Hashtag::String_Piece
    end

    def __tag__component_association

      yield :can, :prepend, :append, :remove

      Home_::Models_::Tag
    end

    ## ~~ assumption & conditional test implementations

    def component_is__present__ * x_a, & x_p
      _route_test :present, * x_a, & x_p
    end

    def component_is_not__present__ * x_a, & x_p
      _route_test :absent, * x_a, & x_p
    end

    def expect_component__present__ qk, & x_p
      _route_test :present, qk, & x_p
    end

    def expect_component__absent__ qk, & x_p
      _route_test :absent, qk, & x_p
    end

    def _route_test adj, qk, & x_p

      send :"__expect__#{ qk.name.as_variegated_symbol }__is__#{ adj }__",
        qk, & x_p
    end

    def __expect__tag__is__present__ qk, & oes_p

      tag = qk.value_x
      existing = first_equivalent_item tag
      if existing
        ACHIEVED_
      else
        ACS_[].send_component_not_found qk, self, & oes_p
      end
    end

    def __expect__tag__is__absent__ qk, & oes_p

      tag = qk.value_x
      existing = first_equivalent_item tag
      if existing
        ACS_[].send_component_already_added qk, self, & oes_p
      else
        ACHIEVED_
      end
    end

    def first_equivalent_item tag  # :+[#ba-051]

      to_tag_stream.flush_until_detect do | tag_ |

        tag == tag_
      end
    end

    ## ~~ implementation of operations

    def __set__component qk, & _x_p

      x = qk.value_x
      instance_variable_set qk.name.as_ivar, x
      x || self._COVER_ME  # as soon as you have valid false-ishes, things change
    end

    def __prepend__component qk, & oes_p_p

      _mutable_body_for_mutation_session.prepend_component_ qk, & oes_p_p
    end

    def __append__component qk, & oes_p_p

      _mutable_body_for_mutation_session.append_component_ qk, & oes_p_p
    end

    def __remove__component qk, & oes_p_p

      o = _mutable_body_for_mutation_session.remove_component_ qk, & oes_p_p
      if o

        _oes_p = oes_p_p[ self ]

        ACS_[].send_component_removed qk, self, & _oes_p
      end
      o
    end

    def _mutable_body_for_mutation_session

      if @body
        if ! @body.is_mutable
          @body = @body.to_mutable
        end
      else
        @body = Node_::Models_::Agnostic_Mutable_Body.new
      end

      @body
    end

    def result_for_component_mutation_session_when_changed o, &_

      @_did_change = true
      o.last_delivery_result
    end

    # -- expression & reflection

    ## ~~ reflection related to tagging

    def is_not_tagged_with sym
      ! is_tagged_with sym
    end

    def is_tagged_with sym

      _ = to_tag_stream.flush_until_detect do | tag |

        sym == tag.intern
      end

      _ ? true : false
    end

    def number_of_times_tagged_with sym

      count = 0

      st = to_tag_stream
      begin
        tag = st.gets
        tag or break
        if sym == tag.intern
          count += 1
        end
        redo
      end while nil

      count
    end

    def to_tag_stream

      if @body
        @body.to_entity_stream_via_model Home_::Models_::Tag
      else
        Common_::Stream.the_empty_stream
      end
    end

    ## ~~ reflection related to e.c

    def has_extended_content

      eca = @_extended_content_adapter
      if eca
        eca.node_has_extended_content_via_node_ID @ID
      end
    end

    ## ~~ hook-ins related to reflection, simple derived & straighforward

    def express_of_via_into_under y, expag

      sym = expag.modality_const

      if sym
        expad_for_( sym ).express_of_via_into_under_of y, expag, self
      else
        express_into_ y
      end
    end

    include Expression_Methods_

    def description_under expag
      y = expag.new_expression_context
      @ID.express_into_under y, expag
      y
    end

    define_method :formal_properties, ( Common_.memoize do

      p = Common_.lib_.basic::Minimal_Property.method :via_variegated_symbol

      [ p[ :identifier ],
        p[ :message ],
        p[ :extended_content ]
      ].freeze
    end )

    def property_value_via_property prp
      send :"__property_value_for__#{ prp.name_symbol }__"
    end

    def __property_value_for__identifier__
      @ID
    end

    def __property_value_for__message__
      @body
    end

    def __property_value_for__extended_content__

      eca = @_extended_content_adapter
      if eca
        eca.any_extended_content_filename_via_node_ID @ID
      end
    end

    def changed
      @_did_change
    end

    attr_reader(
      :body,
      :ID,
    )

    Brazen_ = Home_.lib_.brazen

    class Common_Action_ < Brazen_::Action

      # (this could just as easily be a plain mixin module but it's slightly
      # convenient to be able to establish the entity module in one place)

      Brazen_::Modelesque.entity self

    private

      def resolve_node_only_then_

        _oes_p = handle_event_selectively

        node = @kernel.call_via_mutable_box :node, :to_stream,

          :identifier, @argument_box.remove( :node_identifier ),

          @argument_box,
          & _oes_p

        node and begin
          @node = node
          via_node_only_
        end
      end

      def resolve_node_collection_and_node_then_

        ok = _resolve_node_collection
        ok &&= __via_collection_resolve_node
        ok && via_node_collection_and_node_
      end

      def resolve_node_collection_then_

        _ok = _resolve_node_collection
        _ok && via_node_collection_
      end

      def _resolve_node_collection

        co = Home_::Models_::Node_Collection.new_via_upstream_identifier(
          @argument_box.fetch( :upstream_identifier ),
          & handle_event_selectively )

        co and begin
          @node_collection = co
          ACHIEVED_
        end
      end

      def __via_collection_resolve_node

        node = @node_collection.entity_via_intrinsic_key(
          @argument_box.fetch( :node_identifier ),
          & handle_event_selectively )

        node and begin
          @node = node
          ACHIEVED_
        end
      end

      def persist_node_

        @node_collection.persist_entity(
          @argument_box,
          @node,
          & handle_event_selectively )
      end
    end

    class Common_Body_  # (for three)

      def to_entity_stream_via_model cls

        sym = cls.category_symbol

        to_object_stream_.reduce_by do | o |

          sym == o.category_symbol
        end
      end
    end

    module Mixed_Message___

      # the "message" "component" is something of a virtual component: there
      # is no message "model" per se, however we implement particular
      # messsage-like input and output methods here to accomplish a final
      # goal, for example to append string pieces to a mutable body, or
      # to assemble all of the body lines as one string.

      Expression_Adapters = ::Module.new

      Expression_Adapters::CLI = ::Module.new

      class << Expression_Adapters::CLI

        def express_of_via_under _expag

          -> body do

            y = []

            body.to_business_row_stream_.each do | row |
              s = row.get_business_substring
              s or next
              y << s
            end

            if y.length.nonzero?
              y * SPACE_  # meh
            end
          end
        end
      end

      class << self

        def interpret_component arg_st, & oes_p_p
          Interpret_mixed_message___[ arg_st, & oes_p_p ]
        end
      end  # >>
    end

    Interpret_mixed_message___ = -> arg_st, & x_p do

      x = arg_st.gets_one
      a = ::Array.try_convert x
      a ||= [ x ]
      ok = true
      s_a = []

      a.each do | x_ |

        s = Home_::Models_::Message.normalize_value__ x_, & x_p
        if s
          s_a.push s
        else
          ok = s
          break
        end
      end

      if ok
        Home_::Models::Hashtag::String_Piece.new_via_string s_a * SPACE_
      else
        ok
      end
    end

    Normalize_ID_ = -> qkn, & oes_p do  # 1x. eventing is per [br] API

      x = ( qkn.value_x if qkn.is_known_known )
      if x

        o = Home_::Models_::Node_Identifier.new_via_user_value_ x, & oes_p  # yes

        if o
          Common_::Known_Known[ o ]
        else
          o
        end
      else  # let required/optional handle this, *not* us
        qkn.to_knownness
      end
    end

    module EC___
      module Expression_Adapters
        module CLI ; class << self
          def express_of_via_under _expag
            -> entry_s do

              entry_s
            end
          end
        end ; end
      end
    end

    # ~

    Autoloader_[ ( Actions = ::Module.new ), :boxxy ]

    Autoloader_[ Expression_Adapters = ::Module.new ]

    Autoloader_[ Models_ = ::Module.new ]

    Node_ = self

  end
end
