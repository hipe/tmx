module Skylab::Zerk

  module ArgumentScanner

    class OperatorBranch_VIA_MODULE  # :[#051.B]

      # NOTE this is not covered, hence the scream-case. this is being
      # bleeding-edged by [tab].
      #
      # an adaptation of #[#051] for plain old modules, but with a catch:
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
      #   - [#051.C] (for autoloaderized modules) and
      #   - [#051.G] (for directories thru filesystem directly; no autoloading)

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

      # -

        def initialize mod

          @_custom_emitter = nil
          @_index = Index___.new mod

          yield self

          ce = remove_instance_variable :@_custom_emitter
          if ce
            ce = ce.finish
            @emit_idea_by = -> idea do
              ce[ idea ]
            end
          end

          freeze
        end

        def channel_for_unknown_by & p
          _maybe_customize p, :channel_for_unknown_by=
        end

        def express_unknown_by & p
          _maybe_customize p, :express_unknown_by=
        end

        def _maybe_customize p, m
          if p
            @_custom_emitter ||= Here_::CustomEmitter.new
            @_custom_emitter.send m, p
            NIL
          end
        end

        # -- read

        def lookup_softly k
          @_index.__lookup_softly_ k
        end

        def dereference k
          @_index.__dereference_ k
        end

        def to_pair_stream
          @_index.__to_pair_stream_
        end

        def to_load_ticket_stream
          @_index.__to_normal_symbol_stream_
        end

        attr_reader(
          :emit_idea_by,
        )
      # -
      # ==

      class Index___

        def initialize mod

          bx = Common_::Box.new

          mod.constants.each do |const|
            item = LoadTicket___.new const, mod
            bx.add item.normal_symbol, item
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
          @_box.to_name_stream
        end
      end

      # ==

      class LoadTicket___

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

        def normal_symbol
          @_name.as_lowercase_with_underscores_symbol
        end
      end

      # ==

      # ==
    end
  end
end
# #born: for [tab]
