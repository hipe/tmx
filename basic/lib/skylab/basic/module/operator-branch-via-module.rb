module Skylab::Basic

  class Module::OperatorBranch_via_Module < Common_::SimpleModel  # :[#ze-051.2]

    # ([tab])
    #
    # an adaptation of #[#ze-051] for plain old modules, but with a catch:
    # its implementation is super-dumbed down to work with `boxxy` modules.
    #
    # use this if A) you're using the [#co-030] `boxxy` enhancement on
    # your autoloaderized module or B) all your item nodes are somehow
    # automatically all loaded already (because for example they are all
    # defined in the same file and that file is loaded).
    #
    # if, alternately, you are not using boxxy *and* all your nodes are
    # defined on the filesystem (and isomorphically at that -- no stowaways,
    # one file-or-directory per-node); then look at
    #
    #   - [#ze-051.3] (for autoloaderized modules) (in [ze]) and
    #   - [#ze-051.7] (for directories thru filesystem directly; no autoloading) (in [sy])

    # -

      def initialize

        @_custom_emitter = nil
        @loadable_reference_by = nil

        yield self

        bm = remove_instance_variable :@module  # branch module
        @loadable_reference_by ||= -> const do
          LoadableReference___.new const, bm
        end

        @_index = Index___.new( bm,
          remove_instance_variable( :@loadable_reference_by ) )

        ce = remove_instance_variable :@_custom_emitter
        if ce
          ce = ce.finish
          @emit_idea_by = -> idea do
            ce[ idea ]
          end
        end

        freeze
      end

      # -- totally optional

      def channel_for_unknown_by & p
        _maybe_customize p, :channel_for_unknown_by=
      end

      def express_unknown_by & p
        _maybe_customize p, :express_unknown_by=
      end

      def _maybe_customize p, m
        if p
          @_custom_emitter ||= Home_.lib_.zerk::ArgumentScanner::CustomEmitter.new
          @_custom_emitter.send m, p
          NIL
        end
      end

      # --

      attr_writer(
        :loadable_reference_by,
        :module,
      )

      # -- read

      def lookup_softly k  # #[#ze-051.1] "trueish item value"
        @_index.__lookup_softly_ k
      end

      def dereference k  # #[#ze-051.1] "trueish item value"
        @_index.__dereference_ k
      end

      def to_pair_stream
        @_index.__to_pair_stream_
      end

      def to_loadable_reference_stream
        @_index.__to_normal_symbol_stream_
      end

      attr_reader(
        :emit_idea_by,
      )
    # -
    # ==

    class Index___

      def initialize mod, loadable_reference_by

        bx = Common_::Box.new

        mod.constants.each do |const|
          item = loadable_reference_by[ const ]
          bx.add item.name_symbol, item
        end

        @_box = bx
      end

      def __lookup_softly_ k
        @_box[ k ]
      end

      def __dereference_ k
        @_box.fetch k
      end

      def __to_pair_stream_
        @_box.to_pair_stream
      end

      def __to_normal_symbol_stream_
        @_box.to_key_stream
      end
    end

    # ==

    class LoadableReference___

      def initialize unsanitized_const, box_mod
        @_box_module = box_mod
        @_name = Common_::Name.via_const_symbol unsanitized_const
        @_read = :__read_initially
      end

      def const_value
        send @_read
      end

      def __read_initially

        unsanitized_const = @_name.as_camelcase_const_string

        x = @_box_module.const_get unsanitized_const, false

        if ! @_box_module.const_defined? unsanitized_const, false
          self._COVER_AND_IMPLEMENT_ME_name_correction_etc
          # don't forget to change the @_name too
        end

        @_name.as_const_symbol = unsanitized_const.intern

        remove_instance_variable :@_box_module
        @_read = :__read_normally
        @__value = x
        freeze
        send @_read
      end

      def __read_normally
        @__value
      end

      def name_symbol
        @_name.as_lowercase_with_underscores_symbol
      end
    end

    # ==
    # ==
  end
end
# #history: rewrite when assimilate newer one from [ze]
