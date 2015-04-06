module Skylab::Snag

  class Models_::Tag  # shell / kernel. this is the shell

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

      def normalize_stem_symbol__ stem_i, & oes_p

        ok_arg = Tag_::Stem_Normalization_.
          normalize_argument_value( stem_i, & oes_p )

        ok_arg && ok_arg.value_x
      end
    end  # >>

    Actions = THE_EMPTY_MODULE_

    def initialize kernel
      self._CHECK_THIS
      @kernel = kernel
      freeze
    end

    def stem_i
      @kernel.stem_i
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

    def value
      @kernel.tag_value_x
    end

    # ~ mutators

    def stem_i= x
      @kernel.receive_stem_i x ; x
    end

    class Immutable_Kernel__

      def via_tag_s tag_s, & oes_p

        ok_arg = Tag_::Stem_Normalization_.normalize_argument_value( tag_s, & oes_p )

        if ok_arg
          @stem_i = ok_arg.value_x
          freeze
        else
          ok_arg
        end
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
