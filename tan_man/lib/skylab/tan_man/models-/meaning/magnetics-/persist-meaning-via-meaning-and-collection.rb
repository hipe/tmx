module Skylab::TanMan

  class Models_::Meaning

    class Magnetics_::PersistMeaning_via_Meaning_and_Collection
      # -
        Actor_.call( self,
          :session,
          :change_is_OK,
          :entity,
        )

        def initialize & p
          @on_event_selectively = p
        end

        def execute
          init_ivars
          ok = resolve_insertion_ivars
          ok and rewrite_string
        end

      private

        def init_ivars
          @name = @entity.property_value_via_symbol :name
          @new_line = nil
          @value = @entity.property_value_via_symbol :value
        end

        def resolve_insertion_ivars
          greatest_lesser_name, exact_fly, least_greater_name = find_neighbors
          if exact_fly
            @exact_match_fly = exact_fly
            when_exact_match_fly_resolve_insertion_ivars
          elsif greatest_lesser_name
            @greatest_lesser_name = greatest_lesser_name
            after_greatest_lesser_name_resolve_insertion_ivars
          elsif least_greater_name
            @least_greater_name = least_greater_name
            before_least_greater_name_resolve_insertion_ivars
          else
            when_no_neighbors_resolve_insertion_ivars
          end
        end

        def find_neighbors
          my_name = @name
          @stream = @session.to_stream_of_meanings_with_mutable_string_metadata
          least_greater_name = nil
          while fly = @stream.gets
            name = fly.property_value_via_symbol :name
            case name <=> my_name
            when -1 ; greatest_lesser_name = name
            when  0 ; exact = fly ; break
            when  1 ; least_greater_name ||= name
            end
          end
          [ greatest_lesser_name, exact, least_greater_name ]
        end

        def when_exact_match_fly_resolve_insertion_ivars
          if @change_is_OK
            via_exact_match_resolve_insertion_ivars
          else
            when_name_collision
          end
        end

        def via_exact_match_resolve_insertion_ivars
          o = @reference_meaning = @exact_match_fly
          @insertion_range = o.line_start .. o.end_pos
          @mutable_s = o.whole_string
          ACHIEVED_
        end

        def after_greatest_lesser_name_resolve_insertion_ivars
          @reference_meaning = find_first_flyweight_with_name @greatest_lesser_name
          d = @reference_meaning.next_line_start_pos
          @insertion_range = d ... d
          @mutable_s = @reference_meaning.whole_string
          ACHIEVED_
        end

        def before_least_greater_name_resolve_insertion_ivars
          @reference_meaning = find_first_flyweight_with_name @least_greater_name
          d = @reference_meaning.next_line_start_pos
          @insertion_range = d ... d
          @mutable_s = @reference_meaning.whole_string
          ACHIEVED_
        end

        def find_first_flyweight_with_name s
          @stream = @session.to_stream_of_meanings_with_mutable_string_metadata
          @stream.flush_until_detect do |ent|
            s == ent.property_value_via_symbol( :name )
          end
        end

        def when_no_neighbors_resolve_insertion_ivars
          @new_line = " #{ @name } : #{ @value }\n"
          @mutable_s = @session.fallback_mutable_string
          @mutable_s[ @mutable_s.length, 0 ] = "#"  # because MEH
          @insertion_range = @mutable_s.length ... @mutable_s.length
          ACHIEVED_
        end

        def rewrite_string
          @new_line || resolve_new_line
          @mutable_s[ @insertion_range ] = @new_line  # etc
          ACHIEVED_
        end

        def resolve_new_line
          o = @reference_meaning
          o_x = o.line_start
          its_width_to_colon = o.colon_pos - o_x
          its_e2_width = o.colon_pos - o.name_range.end - 1
          its_e0 = o.whole_string[ o_x .. o.name_range.begin - 1 ]
          its_e0 = sanitize_e0 its_e0
          e0 = "#{ its_e0 }#{
            SPACE_ * [ 0,
          ( its_width_to_colon - its_e2_width - @name.length - its_e0.length )
                   ].max
          }"
          e2 = SPACE_ * its_e2_width
          e4 = SPACE_ * ( o.value_range.begin - 1 - o.colon_pos )
          @new_line = "#{ e0 }#{ @name }#{ e2 }:#{ e4 }#{ @value }\n" ; nil
        end

        def sanitize_e0 its_e0
          if C_STYLE_OPEN_COMMENT_RX_ =~ its_e0
            SPACE_ * its_e0.length
          else
            its_e0.gsub TRAILING_WHITESPACE_RX__, EMPTY_S_
          end
        end

        def when_name_collision
          value = @exact_match_fly.property_value_via_symbol :value
          if value == @value
            when_no_change
          else
            when_will_not_clobber
          end
        end

        def when_no_change
          maybe_send_event :error, :no_change do
            bld_no_change_event
          end
          UNABLE_
        end

        def bld_no_change_event
          build_not_OK_event_with :no_change,
              :name, @name, :value, @value do |y, o|
            y << "#{ lbl o.name } is already set to #{ val o.value }."
          end
        end

        def when_will_not_clobber
          maybe_send_event :error, :name_collision do
            bld_name_collision_event
          end
          UNABLE_
        end

        def bld_name_collision_event
          build_not_OK_event_with :name_collision,
              :name, @name,
              :existing_value, @exact_match_fly.property_value_via_symbol( :value ),
              :replacement_value, @value do |y, o|

            y << "cannot set #{ lbl o.name } to #{ val o.replacement_value },#{
             } it is already set to #{ val o.existing_value }"
          end
        end


        C_STYLE_OPEN_COMMENT_RX_ = /\A[ \t]*\/\*/
        TRAILING_WHITESPACE_RX__ = /[ \t]+\z/
      # -
    end
  end
end
