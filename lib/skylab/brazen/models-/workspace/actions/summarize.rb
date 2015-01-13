module Skylab::Brazen

  class Models_::Workspace

    class Actions::Summarize < Brazen_::Model_::Action

      Brazen_::Model_::Entity.call self do

        o :required, :property, :path

      end

      def produce_any_result

        bx = @argument_box

        model_class.merge_workspace_resolution_properties_into_via bx, self

        @prop = self.class.properties.fetch :path
        @ws = model_class.edit_entity @kernel, handle_event_selectively do |o|
          o.preconditions @preconditions
          o.argument_box bx
          o.edit_with :prop, @prop
        end
        @ws and via_ws
      end

      def via_ws
        pn = @ws.execute
        pn and when_pn
      end

      def when_pn
        @ds = @ws.datastore
        @ds and via_ds
      end

      def via_ds
        @scn = @ds.to_section_stream( & handle_event_selectively )
        @box = Box_.new
        one = -> { 1 } ; increment = -> d { d + 1 }
        while sect = @scn.gets
          _i = sect.external_normal_name_symbol
          @box.add_or_replace _i, one, increment
        end
        via_box
      end

      def via_box
        maybe_send_event :info, :summary do
          bld_summary_event
        end
      end

      def bld_summary_event
        build_OK_event_with :summary, :box, @box, :ws, @ws do |y, o|
          y << "summary of #{ o.ws.description_under self }:"
          scn = o.box.to_pair_stream
          count = 0
          while pair = scn.gets
            count += 1
            d, i = pair.to_a
            s = i.id2name
            s.gsub! DASH_, SPACE_
            y << "  • #{ d } #{ plural_noun s, d }"
          end
          y << "#{ count } section#{ s count } total"
        end
      end
    end
  end
end
