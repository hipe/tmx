module Skylab::Snag

  class Models_::Node

    class << self

      def interpret_out_of_under_ x, x_, k, & oes_p

        Node_::Expression_Adapters.const_get( x.modality_const, false ).
          interpret_out_of_under_ x, x_, k, & oes_p
      end

      def new_via_body body
        new nil, body
      end

      def new_via_identifier id_o
        new id_o
      end

      def new_via_identifier_and_body id_o, body
        new id_o, body
      end

      def new_via__message__ s_OR_s_a, & oes_p

        s_a = ::Array.try_convert s_OR_s_a
        s_a ||= [ s_OR_s_a ]
        __new_via_message_ary s_a, & oes_p
      end

      def __new_via_message_ary s_a, & oes_p

        o = new
        ok = true
        s_a.each do | s |

          arg = Snag_::Models_::Message.normalize_argument(
            Callback_::Trio.new( s, true ), & oes_p )

          if arg
            ok = o.edit :append, :string, arg.value_x, & oes_p
          else
            ok = arg
            break
          end
        end
        ok && o
      end

      private :new
    end

    def initialize id_o=nil, body=nil

      @body = body

      @_did_change = false

      @_extended_content_adapter = if body
        body.extended_content_adapter_
      end

      if id_o
        id_o.respond_to?( :suffix ) or raise ::ArgumentError, "where? #{ id_o.class }"
        @ID = id_o
      end
    end

    def reinitialize id_o

      if id_o
        id_o.respond_to?( :suffix ) or raise ::ArgumentError, "where? #{ id_o.class }"
      end

      @ID = id_o
      NIL_
    end

    def initialize_copy _
      @body = @body.dup
      NIL_
    end

    attr_reader :body, :ID

    def changed
      @_did_change
    end

    # ~

    include Expression_Methods_

    def description_under expag
      y = expag.new_expression_context
      @ID.express_into_under y, expag
      y
    end

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

    def has_equivalent__tag__object_ o

      _ = to_tag_stream.detect do | tag |

        o == tag
      end

      _ ? true : false
    end

    def to_tag_stream

      if @body
        @body.entity_stream_via_model Snag_::Models_::Tag
      else
        Callback_::Stream.the_empty_stream
      end
    end

    def prepend_tag symbol, & oes_p

      edit :prepend, :tag, :symbol, symbol, & oes_p
    end

    def append_tag symbol, & oes_p

      edit :append, :tag, :symbol, symbol, & oes_p
    end

    def remove_tag symbol, & oes_p

      self._COVER_ME
      edit :remove, :tag, :symbol, symbol, & oes_p
    end

    # ~

    def edit * x_a, & x_p

      Snag_::Model_::Collection::Mutation_Session.call x_a, self, & x_p
    end

    def mutable_body_for_mutation_session_by verb_symbol

      case verb_symbol
      when :receive
        self
      when :prepend, :append, :remove
        __mutable_body
      end
    end

    def __mutable_body

      if @body
        if ! @body.is_mutable
          @body = @body.to_mutable
        end
      else
        @body = Node_::Models_::Agnostic_Mutable_Body.new
      end
      @body
    end

    def __identifier__class_for_mutation_session

      Snag_::Models_::Node_Identifier
    end

    def __string__class_for_mutation_session

      Snag_::Models::Hashtag::String_Piece
    end

    def __tag__class_for_mutation_session

      Snag_::Models_::Tag
    end

    def receive_notification_of_change_during_mutation_session

      @_did_change = true
      ACHIEVED_
    end

    # ~

    def has_extended_content
      @_extended_content_adapter.node_has_extended_content_via_node_id @ID
    end

    # ~

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

        h = @argument_box.h_

        _silo = @kernel.silo :node_collection

        co = _silo.node_collection_via_upstream_identifier(
          h.fetch( :upstream_identifier ),
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

    Normalize_ID_ = -> arg, & oes_p do

      Snag_::Models_::Node_Identifier.
        interpret_out_of_under( arg, :User_Argument, & oes_p )
    end

    # ~

    Autoloader_[ ( Actions = ::Module.new ), :boxxy ]

    Autoloader_[ Expression_Adapters = ::Module.new ]

    Autoloader_[ Models_ = ::Module.new ]

    Node_ = self

  end
end
