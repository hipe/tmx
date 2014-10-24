module Skylab::CodeMolester

  module Models

    module Config

      class Actors_::Create

        Callback_::Actor[ self, :properties,

          :ent, :opt_h, :event_h, :file_model, :file_controller ]

        def execute
          init_ivars
          ok = resolve_any_lesser
          ok && the_rest
          @result
        end

      private

        def init_ivars
          @couldnt, @could = unpack_subset @event_h, :couldnt, :could
          @section_name = "#{ @ent.config_file_section_name } #{
            }#{ @ent.natural_key.inspect }"
          @secs = @file_model.sections  # if any
        end

        def resolve_any_lesser
          if @secs
            via_sections_resolve_lesser
          else
            @lesser = nil
            DID_
          end
        end

        def via_sections_resolve_lesser
          ok = DID_
          @lesser = nil
          scan = @secs.to_scan
          sect = scan.gets
          while sect
            _cmp = @section_name <=> sect.section_name
            case _cmp
            when -1
              break
            when 1
              @lesser = sec
            else
              @result = send_event Collision__[ :ent, @ent ]
              ok = UNABLE_
              break
            end
            sect = scan.gets
          end
          ok
        end

        def the_rest
          _pairs = @ent.rendered_surface_pairs
          @file_model.sexp.insert_pairs_and_name_immediately_after_section(
            _pairs,
            @section_name,
            @lesser )
          @could[ Inserted__[ :item, @ent ] ]

          @result = @file_controller.write @opt_h, repack_difference( @event_h, :could )
          nil
        end

        def send_event ev
          @couldnt[ ev ]
        end

        Inserted__ = Event_.new do |item|
          "inserted into list - #{ item.natural_key.inspect }"
        end

        Collision__ = Event_.new do |ent|
          "#{ ent.inflection.lexemes.noun.singular } already exists, #{
            }won't clobber - #{ ent.natural_key }"
        end

        Lib_::Hash_lib[].pairs_at(
          :repack_difference,
          :unpack_subset,
          & method( :define_method ) )

      end
    end
  end
end
