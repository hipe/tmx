module Skylab::Brazen

  class Models_::Workspace

    class Actions::Summarize < Home_::Action

      edit_entity_class(
        :property_object, COMMON_PROPERTIES_[ :config_filename ],
        :required, :property, :path,
      )

      def produce_result
        ok = resolve_existent_workspace
        ok &&= @_workspace.resolve_document_( & handle_event_selectively )
        ok && work
      end

      def resolve_existent_workspace

        bx = @argument_box

        ws = silo_module.edit_entity @kernel, handle_event_selectively do |o|
          o.preconditions @preconditions
          o.edit_with(
            :surrounding_path, bx.fetch( :path ),
            :config_filename, bx.fetch( :config_filename ) )
        end

        if ws
          @_workspace = ws

          _prp = formal_properties.fetch :path

          ws.resolve_nearest_existent_surrounding_path(
            ONLY_LOOK_IN_THE_FIRST_DIRECTORY___,
            :prop, _prp,
            & handle_event_selectively )

        else
          ws
        end
      end

      ONLY_LOOK_IN_THE_FIRST_DIRECTORY___ = 1  # for now, searching upwards is not an option

      def work
        bx = Box_.new
        one = -> { 1 }
        increment = -> d { d + 1 }
        st = @_workspace.document_.to_section_stream( & handle_event_selectively )
        sect = st.gets

        while sect
          bx.add_or_replace sect.external_normal_name_symbol, one, increment
          sect = st.gets
        end

        @box = bx

        Callback_::Emission.of :info, :summary do
          ___build_summary_event
        end
      end

      def ___build_summary_event

        build_OK_event_with :summary, :box, @box, :ws, @_workspace do |y, o|

          y << "summary of #{ o.ws.description_under self }:"

          st = o.box.to_pair_stream
          count = 0
          begin
            pair = st.gets
            pair or break
            count += 1
            d, i = pair.to_a
            s = i.id2name
            s.gsub! DASH_, SPACE_
            y << "  • #{ d } #{ plural_noun d, s }"
            redo
          end while nil

          y << "#{ count } section#{ s count } total"
        end
      end
    end
  end
end
