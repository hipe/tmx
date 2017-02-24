module Skylab::MyTerm

  class CLI

    module Interactive

      # for interactive CLI, the customization necessary mostly involves
      # the usual needing to chose aesthetically appropriate "hotrings".
      # also it is necessary to hook into something so we know when the
      # adapter changes.

      class << self

        def build_classesque__  # #test-point

          _cli = begin_CLI_
          _cli.to_classesque
        end

        def begin_CLI_

          Require_zerk_[]

          cli = Zerk_::InteractiveCLI.begin

          cli.root_ACS_by do  # #cold-model
            Home_.build_root_ACS_
          end

          cli.design = -> vmm do
            vmm.compound_frame = vmm.common_compound_frame
            vmm.custom_tree_array_proc = CUSTOM_TREE___
            vmm.location = vmm.common_location
            vmm.primitive_frame = vmm.common_primitive_frame
            vmm
          end

          cli
        end
      end  # >>

      # ==

      adapter_changed = nil

      CUSTOM_TREE___ = -> do
        [
          :children, {

            adapter: -> do
              [
                :hotstring_delineation, [nil, 'a', 'dapter'],
                :on_change, adapter_changed,
              ]
            end,

            adapters: -> do
              [
                :hotstring_delineation, ['adapter', 's', nil],
              ]
            end,

            background_font: -> o do
              o.hotstring_delineation %w(background- f ont)
            end,

            bg_font: -> o do
              o.mask
            end,

            fill_color: -> o do
              o.hotstring_delineation %w( fill- c olor )
            end,

            size: -> o do
              o.hotstring_delineation %w( si z e )
            end,

            eg_compound_1: -> do
              [
                :children, {
                  eg_primi_1: -> do
                    [
                      :hotstring_delineation, [xx],
                      :custom_view_controller, -> * a do
                        Home_::CLI::Inveractive.new( * a )
                      end,
                    ]
                  end,
                },
              ]
            end,
          },
        ]
      end

      # ==

      adapter_changed = -> adapter_frame do

        # "appearance" is the root frame and it has as one of its immediate
        # children nodes the "adapter" atomesque. subject is called when
        # that component value has changed. when this happens we need to
        # let the modality know so that it can do whatever re-indexing or
        # clearing of caches (etc) is necessary to reflect this change in
        # its generated UI (so that newly available component (references)
        # appear).

        root_frame = adapter_frame.below_frame

        root_frame.CHANGE_ACS root_frame.ACS.adapter.implementation_

        NIL_
      end
    end
  end
end
