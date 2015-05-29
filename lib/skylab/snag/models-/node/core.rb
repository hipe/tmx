module Skylab::Snag

  class Models_::Node

    module Criteria  # ersatz class as proxy

      class << self

        def new s_a

          Snag_::Models_::Criteria.new_via_expression(
            s_a,
            Snag_.application_kernel_ )
        end
      end  # >>
    end

    class << self

      def interpret_for_mutation_session arg_st, & x_p

        Snag_.lib_.brazen::Mutation_Session.interpret arg_st, self, & x_p
      end

      def edit_entity * x_a, & x_p  # ..

        Snag_.lib_.brazen::Mutation_Session.create x_a, self, & x_p
      end

      def collection_module_for_criteria_resolution

        Snag_::Models_::Node_Collection
      end

      def new_via_body x  # :+#ACS-tenet-8B

        new nil, x
      end

      def new_via__identifier__ x

        new x
      end

      def new_empty_for_mutation_session

        new
      end

      # ~ :+#ACS-tenet-7

      def __extended_content__association_for_mutation_session
        EC___
      end

      def __identifier__association_for_mutation_session

        Snag_::Models_::Node_Identifier
      end

      def __message__association_for_mutation_session

        Mixed_Message___
      end

      def __string__association_for_mutation_session

        Snag_::Models::Hashtag::String_Piece
      end

      def __tag__association_for_mutation_session

        Snag_::Models_::Tag
      end

      private :new  # :+#ACS-tenet-1
    end  # >>

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

    attr_reader :body, :ID

    def changed
      @_did_change
    end

    # ~

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

      @_extended_content_adapter.any_extended_content_filename_via_node_ID @ID
    end

    define_method :formal_properties, ( Callback_.memoize do

      p = Callback_.lib_.basic::Minimal_Property.method :via_variegated_symbol

      [ p[ :identifier ],
        p[ :message ],
        p[ :extended_content ]
      ].freeze
    end )
    # ~

    def receive__identifier__for_mutation_session o

      @ID = o
      ACHIEVED_
    end

    # ~

    def append_string s, & oes_p

      edit :append, :string, s, & oes_p
    end

    def prepend_string s, & oes_p

      edit :prepend, :string, s, & oes_p
    end

    # ~

    def is_not_tagged_with sym
      ! is_tagged_with sym
    end

    def is_tagged_with sym

      _ = to_tag_stream.detect do | tag |

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

    def has_equivalent__tag__for_mutation_session o

      _ = to_tag_stream.detect do | tag |

        o == tag
      end

      _ ? true : false
    end

    def to_tag_stream

      if @body
        @body.to_entity_stream_via_model Snag_::Models_::Tag
      else
        Callback_::Stream.the_empty_stream
      end
    end

    def prepend_tag symbol, & oes_p

      edit :prepend, :tag, symbol, & oes_p
    end

    def append_tag symbol, & oes_p

      edit :append, :tag, symbol, & oes_p
    end

    def remove_tag symbol, & oes_p

      self._COVER_ME
      edit :remove, :tag, symbol, & oes_p
    end

    # ~

    def edit * x_a, & x_p

      Snag_.lib_.brazen::Mutation_Session.edit x_a, self, & x_p
    end

    def mutable_body_for_mutation_session

      if @body
        if ! @body.is_mutable
          @body = @body.to_mutable
        end
      else
        @body = Node_::Models_::Agnostic_Mutable_Body.new
      end
      @body
    end

    def receive_changed_during_mutation_session

      @_did_change = true
      ACHIEVED_
    end

    # ~

    def has_extended_content
      @_extended_content_adapter.node_has_extended_content_via_node_ID @ID
    end

    Brazen_ = Snag_.lib_.brazen

    class Common_Action < Brazen_::Model.common_action_class

      # (this could just as easily be a plain mixin module but it's slightly
      # convenient to be able to establish the entity module in one place)

      Brazen_::Model.common_entity self

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

        co = Snag_::Models_::Node_Collection.new_via_upstream_identifier(
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
      module Expression_Adapters::CLI ; class << self
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
      end ; end

      class << self

        def interpret_for_mutation_session arg_st, & x_p
          Interpret_mixed_message___[ arg_st, & x_p ]
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

        s = Snag_::Models_::Message.normalize_value__ x_, & x_p
        if s
          s_a.push s
        else
          ok = s
          break
        end
      end

      if ok
        Snag_::Models::Hashtag::String_Piece.new_via_string s_a * SPACE_
      else
        ok
      end
    end

    Normalize_ID_ = -> arg, & x_p do

      x = arg.value_x
      if x
        o = Snag_::Models_::Node_Identifier.new_via_user_value x, & x_p
        if o
          arg.new_with_value o
        else
          o
        end
      else  # let required/optional handle this, *not* us
        arg
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
