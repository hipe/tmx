module Skylab::TMX

  class CLI

    class Magnetics_::OperatorBranch_via_InstalledSidesystems < SimpleModel_ # 1x

      # when the front element of the ARGV directly corresponds to a
      # sidesystem (gem), then resolution of the remote operator is much
      # more straightforward than having to load possibly the whole tree.

      # tons of assumptions about names and interfaces.. #hook-out

      # -

        attr_writer(
          :CLI,
          :installation,
        )

        def lookup_softly sym  # #[#ze-051.1] "trueish item value"
          _ = @installation.loadable_reference_via_normal_symbol_softly sym
          _  # #todo
        end

        def dereference lt
          _sym = lt.category_symbol  # [#ze-062]
          :zerk_sidesystem_loadable_reference_category_symbol == _sym || self._OK_FINE
          lt
        end

        def to_loadable_reference_stream  # 1x [ze]

          # this comports with "no-deps" [ze] which nominally works in
          # symbols but actually (and experimentally) we use loadable references

          # because this is so experimental, we map the stream to itself
          # just so this touches down here at each step.

          lt_st = @installation.to_sidesystem_reference_stream
          -> do
            lt_st.gets  # hi.
          end
        end

        def __CODE_SKETCH__

          # :[#007.B]: if you're wondering how you might reach the same
          # sort of stream we see in the `map` operation, it might look
          # like this (it worked until we hit a wall with needing load
          # references to get descriptions).
          #
          # the main reason we backed off from this approach was the idea
          # that what's more approprite for The TMX is that it uses the gems
          # that happen to be installed at the moment, and not the
          # directories that happen to be in the "development" directory.
          #
          # details: the `map` operation is populated by the results of a
          # glob derived from the *development directory* (which is derived
          # from the home directory of [tmx] which, in turn, is deep-
          # normalized to dereference all symlinks from it). longterm this
          # approach wouldn't fly, because this technique wouldn't be useful
          # for "normal" installations.

          st = @CLI.json_file_stream_by__.call( & @CLI.listener )
          if st
            _st_ = Home_::Models_::Node::Parsed::Unparsed::Stream_via_json_file_stream[ st ]
            _st_.reduce_by do |node|
              node.get_filesystem_directory_entry_string.intern
            end
          end
        end

        def bound_call_for_help_via_loadable_reference__ lt
          Magnetics_::BoundCall_via_LoadableReference.define do |o|
            o.is_for_help = true
            o.loadable_reference = lt
            o.CLI = @CLI
          end.execute
        end

        def bound_call_for_invocation_via_loadable_reference__ lt
          Magnetics_::BoundCall_via_LoadableReference[ lt, @CLI ]
        end
      # -

      # ==
      # ==
    end
  end
end
