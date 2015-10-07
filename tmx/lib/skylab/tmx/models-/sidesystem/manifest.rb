module Skylab::TMX

  module Models_::Sidesystem

    class Manifest

      def initialize items, load_ticket

        @_items = items
        @_load_ticket = load_ticket
        @_gne = load_ticket.gem_name_elements

        _slug = @_gne.stem.gsub UNDERSCORE_, DASH_

        _conventional_entrypoint_entry = "#{ @_gne.exe_prefix }#{ _slug }"

        if items.include? _conventional_entrypoint_entry
          @_thing_method = :__to_unboundish_stream_when_showcase_sidesystem
        else
          @_thing_method = :__to_unboundish_stream_when_rogue_sidesystem
        end
      end

      def to_unboundish_stream
        send @_thing_method
      end

      def __to_unboundish_stream_when_showcase_sidesystem

        # a showcase sidesystem has only itslf to show.

        ss_mod = _sidesys_mod

        _nf = Callback_::Name.via_module ss_mod

        _unb = Home_::Model_::Showcase_as_Unbound.new _nf, ss_mod

        Callback_::Stream.via_item _unb
      end

      def __to_unboundish_stream_when_rogue_sidesystem

        Callback_::Stream.via_item Rogue_as_Unbound.new self
      end

      def _sidesys_mod
        @_load_ticket.require_sidesystem_module
      end

      def __child_count
        @_items.length
      end

      # "rougue" is experimental

      class Rogue_as_Unbound

        def initialize mani

          @_mani = mani
          @_nf = Callback_::Name.via_module mani._sidesys_mod
        end

        def adapter_class_for _
          self
        end

        def new _self, bound_parent_action, & x_p

          Rogue_as_Bound___.new bound_parent_action, @_nf, @_mani, & x_p
        end

        def name_function
          @_nf
        end
      end

      class Rogue_as_Bound___

        include Home_::Model_::Common_Bound_Methods

        def initialize bound_parent_action, nf, mani, & oes_p

          @_mani = mani
          @nf_ = nf
        end

        def under_expression_agent_get_N_desc_lines expag, n=nil
          nm = @nf_
          d = @_mani.__child_count
          expag.calculate do
            [ "#{ nm.as_slug }: #{ d } small utilit#{ s d, :y }" ]
          end
        end
      end
    end
  end
end
