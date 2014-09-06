module Skylab::TanMan

  class Models_::Meaning

    class Collection_Controller__

      class Persist

        Callback_::Actor[ self, :properties, :ent, :output_s, :scan_p, :channel, :action ]

        TanMan_::Lib_::Event_builder[ self ]

        def execute
          init_ivars
          ok = resolve_insertion_range
          ok and rewrite_string
        end

      private

        def init_ivars
          @name = @action.action_property_value :name
          @new_line = nil
          @value = @action.action_property_value :value
        end

        def resolve_insertion_range
          greatest_lesser_name, exact_fly, least_greater_name = find_neighbors
          if exact_fly
            @exact_match_fly = exact_fly
            when_exact_match_fly_resolve_insertion_range
          elsif greatest_lesser_name
            @greatest_lesser_name = greatest_lesser_name
            after_greatest_lesser_name_resolve_insertion_range
          elsif least_greater_name
            @least_greater_name = least_greater_name
            before_least_greater_name_resolve_insertion_range
          else
            when_no_neighbors_resolve_insertion_range
          end
        end

        def find_neighbors
          my_name = @name
          @scan = produce_fresh_scanner
          least_greater_name = nil
          while fly = @scan.gets
            name = fly.name
            case name <=> my_name
            when -1 ; greatest_lesser_name = name
            when  0 ; exact = fly ; break
            when  1 ; least_greater_name ||= name
            end
          end
          [ greatest_lesser_name, exact, least_greater_name ]
        end

        def when_exact_match_fly_resolve_insertion_range
          _change_OK = :change == @action.name.as_lowercase_with_underscores_symbol  # #todo
          if _change_OK
            when_change_OK
          else
            when_name_collision
          end
        end

        def after_greatest_lesser_name_resolve_insertion_range
          @example = find_first_flyweight_with_name @greatest_lesser_name
          d = @example.next_line_start_pos
          @insertion_range = d .. d-1 ; ACHEIVED_
        end

        def before_least_greater_name_resolve_insertion_range
          @example = find_first_flyweight_with_name @least_greater_name
          d = @example.next_line_start_pos
          @insertion_range = d .. d-1 ; ACHEIVED_
        end

        def find_first_flyweight_with_name s
          @scan = produce_fresh_scanner
          @scan.detect do |x|
            s == x.name
          end
        end

        def when_no_neighbors_resolve_insertion_range
          @new_line = " #{ @name } : #{ @value }\n"
          d = @scan.last_end_position
          @insertion_range = d .. d-1 ; ACHEIVED_
        end

        def rewrite_string
          @new_line || resolve_new_line
          @output_s[ @insertion_range ] = @new_line
          ACHEIVED_
        end

        def resolve_new_line
          o = @example
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
          value = @exact_match_fly.value
          if value == @value
            when_no_change
          else
            when_will_not_clobber
          end
        end

        def when_no_change
          _ev = build_error_event_with :no_change,
              :name, @name, :value, @value do |y, o|
            y << "#{ lbl o.name } is already set to #{ val o.value }."
          end
          send_event _ev ; UNABLE_
        end

        def when_will_not_clobber
          _ev = build_error_event_with :name_collision,
              :name, @name, :existing_value, @exact_match_fly.value,
              :replacement_value, @value do |y, o|
            y << "cannot set #{ lbl o.name } to #{ val o.replacement_value },#{
             } it is already set to #{ val o.existing_value }"
          end
          send_event _ev ; UNABLE_
        end

        def produce_fresh_scanner
          @scan_p[]
        end

        def send_event ev
          @action.send :"receive_#{ @channel }_event", ev ; nil
        end

        C_STYLE_OPEN_COMMENT_RX_ = /\A[ \t]*\/\*/
        EMPTY_S_ = ''.freeze
        SPACE_ = ' '.freeze
        TRAILING_WHITESPACE_RX__ = /[ \t]+\z/
      end
    end
  end
end
