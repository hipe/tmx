module Skylab::Snag

  class Models_::Node

    Actions = THE_EMPTY_MODULE_

    def initialize node_ID_object=nil, body=nil

      @body = body
      @changed = false
      @ID = if node_ID_object
        Snag_::Models_::Node_Identifier.try_convert node_ID_object
      else
        node_ID_object
      end
    end

    attr_reader :body, :changed, :ID

    # ~

    def express_into_under y, expag

      _expad_for( expag ).express_into_under_of y, expag, self
    end

    def express_N_units_into_under d, y, expag

      _expad_for( expag ).express_N_units_into_under_of d, y, expag, self
    end

    def _expad_for expag
      Node_::Expression_Adapters.const_get expag.modality_const, false
    end

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

    Autoloader_[ Models_ = ::Module.new ]

    Node_ = self
  end
end
