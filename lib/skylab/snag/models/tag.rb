module Skylab::Snag

  class Models::Tag  # shell / kernel. this is the shell

    class << self
      def canonical_tags
        CANONICAL_TAGS__[]
      end

      def controller lstn
        new Tag_::Controller__.new lstn
      end

      def immutable tag_s
        new Immutable_Kernel__.new.via_tag_s tag_s
      end

      def normalize_stem_i stem_i, error_p=nil, info_p=nil
        _listener = if error_p || info_p
          Snag_::Model_::Info_Error_Listener.new info_p, error_p
        else
          Snag_::Model_::THROWING_INFO_ERROR_LISTENER
        end
        o = Tag_::Stem_Normalization_.new _listener
        o.stem_i = stem_i
        if o.is_valid
          o.stem_i
        else
          o.result_of_last_callback_called
        end
      end
    end

    def initialize kernel
      @kernel = kernel
      freeze
    end

    def to_s
      @kernel.to_string
    end

    def render
      @kernel.to_string
    end

    # ~ validation readers

    def is_valid
      @kernel.is_valid
    end

    def last_callback_result
      @kernel.last_callback_result
    end

    # ~ specialy readers & producers

    def pos
      @kernel.tag_start_offset_in_node_body_string
    end

    def duplicate
      self.class.new @kernel.duplicate_kernel
    end

    # ~ mutators

    def stem_i= x
      @kernel.receive_stem_i x ; x
    end

    class Immutable_Kernel__

      def via_tag_s tag_s
        @stem_i = Tag_::Stem_Normalization_.
          new.with_tag_s( tag_s ).valid.stem_i.freeze
        freeze
      end

      def to_string
        "##{ @stem_i }"
      end
    end

    CANONICAL_TAGS__ = -> do
      p = -> do
        Canonical_Tags___ = ::Struct.new :open_tag
        o = Canonical_Tags___.new
        o.open_tag = Tag_.immutable '#open'
        o.freeze
        p = -> { o } ; o
      end
      -> { p.call }
    end.call

    Tag_ = self
  end
end
