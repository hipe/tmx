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

      @_extended_content_adapter = if body
        body.extended_content_adapter_
      end

      @changed = false
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

    attr_reader :body, :changed, :ID

    # ~

    include Expression_Methods_

    # ~

    def append_string s, & oes_p

      _as_for_string s, :append_object, & oes_p
    end

    def prepend_string s, & oes_p

      _as_for_string s, :prepend_object, & oes_p
    end

    def _as_for_string s, method, & oes_p

      _piece = Snag_::Models::Hashtag::String_Piece.new s

      _ensure_mutable_body
      ok = @body.send method, _piece, & oes_p
      ok and @changed = true
      ok
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

    def to_tag_stream

      if @body
        @body.entity_stream_via_model Snag_::Models_::Tag
      else
        Callback_::Stream.the_empty_stream
      end
    end

    def append_tag symbol, & oes_p

      _as_for_tag symbol, :append_object, & oes_p
    end

    def prepend_tag symbol, & oes_p

      _as_for_tag symbol, :prepend_object, & oes_p
    end

    def remove_tag symbol, & oes_p

      _as_for_tag symbol, :remove_equivalent_object, & oes_p
    end

    def _as_for_tag symbol, method, & oes_p

      tag = Snag_::Models_::Tag.new_via_symbol symbol, & oes_p

      tag and begin
        _ensure_mutable_body
        ok = @body.send method, tag, & oes_p
        ok and @changed = true
        ok
      end
    end

    # ~

    def has_extended_content
      @_extended_content_adapter.node_has_extended_content_via_node_id @ID
    end

    # ~

    def _ensure_mutable_body

      if @body
        if ! @body.is_mutable
          @body = @body.to_mutable
        end
      else
        @body = Node_::Models_::Agnostic_Mutable_Body.new
      end
      NIL_
    end

    Autoloader_[ Expression_Adapters = ::Module.new ]

    Autoloader_[ Models_ = ::Module.new ]

    Brazen_ = Snag_.lib_.brazen

    Node_ = self
  end
end
