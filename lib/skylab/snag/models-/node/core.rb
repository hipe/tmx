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

      private :new
    end

    def initialize id_o=nil, body=nil

      @body = body
      @collection_was_changed_by_mutation_session_ = false

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
      @muation_session_changed_collection_
    end

    # ~

    include Expression_Methods_

    def description_under expag
      y = expag.new_expression_context
      @ID.express_into_under y, expag
      y
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

      self._SEE_STASH
    end

    # ~

    def edit * x_a, & x_p

      Snag_::Model_::Collection::Mutation_Session.call x_a, self, & x_p
    end

    def mutable_body_for_mutation_session_

      if @body
        if ! @body.is_mutable
          @body = @body.to_mutable
        end
      else
        @body = Node_::Models_::Agnostic_Mutable_Body.new
      end
      @body
    end

    def __string__class_for_mutation_session_

      Snag_::Models::Hashtag::String_Piece
    end

    def __tag__class_for_mutation_session_

      Snag_::Models_::Tag
    end

    attr_writer :collection_was_changed_by_mutation_session_

    # ~

    def has_extended_content
      @_extended_content_adapter.node_has_extended_content_via_node_id @ID
    end

    # ~

    Autoloader_[ Expression_Adapters = ::Module.new ]

    Autoloader_[ Models_ = ::Module.new ]

    Brazen_ = Snag_.lib_.brazen
    Node_ = self
  end
end
