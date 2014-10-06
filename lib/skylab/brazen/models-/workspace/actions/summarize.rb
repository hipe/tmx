module Skylab::Brazen

  class Models_::Workspace

    class Actions::Summarize < Brazen_::Model_::Action

      Brazen_::Model_::Entity[ self, -> do

        o :required, :property, :path

      end ]

      def produce_any_result

        bx = @argument_box

        model_class.merge_workspace_resolution_properties_into_via bx, self

        @prop = self.class.properties.fetch :path
        @ws = model_class.edited self, @kernel do |o|
          o.with_preconditions @preconditions
          o.with_argument_box bx
          o.with :prop, @prop
        end
        @ws.error_count.zero? and via_ws
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
        @scn = @ds.section_scan self
        @box = Box_.new
        one = -> { 1 } ; increment = -> d { d + 1 }
        while sect = @scn.gets
          _i = sect.normalized_name_i
          @box.add_or_replace _i, one, increment
        end
        via_box
      end

      def via_box
        _ev = build_OK_event_with :summary, :box, @box, :ws, @ws do |y, o|
          y << "summary of #{ o.ws.description_under self }:"
          scn = o.box.to_pair_scan
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
        send_event _ev
      end
    end
  end
end
