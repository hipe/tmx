module Skylab::TanMan

  module Models_::Meaning

    class Magnetics_::PersistMeaning_via_Meaning_and_Collection < Common_::MagneticBySimpleModel

      # yet another implementation (in this app) of #[#tm-011] unobtrusive
      # lexicalesque ordering

      # the subject was written before the conventions contemporary with
      # this comment, both of ivars and of method names. we have
      # contempified the method names but left the ivars as-is so they stay
      # connected to history for now (because there's so many of them) #history-A.1

      # -

        def initialize
          @new_line = nil  # bc #here1
          super
        end

        # ~( keeping these two legacy names for the ivars for now

        def value_string= s
          @value = s
        end

        def name_string= s
          @name = s
        end

        # ~)

        def force_is_present= yes
          if yes
            @_has_force = :__TRUE
          else
            @_has_force = :__FALSE
          end
          yes
        end

        attr_writer(
          :entity_stream_by,
          :listener,
          :fallback_mutable_string,
          :session,
        )

        def execute
          ok = __normalize_name_and_value
          ok &&= __resolve_insertion_ivars
          ok && __rewrite_string
        end

        def __resolve_insertion_ivars
          greatest_lesser_name, exact_fly, least_greater_name = __find_neighbors
          if exact_fly
            @exact_match_fly = exact_fly
            __when_exact_match_fly_resolve_insertion_ivars
          elsif greatest_lesser_name
            @greatest_lesser_name = greatest_lesser_name
            __after_greatest_lesser_name_init_insertion_ivars
          elsif least_greater_name
            @least_greater_name = least_greater_name
            __before_least_greater_name_init_insertion_ivars
          else
            __when_no_neighbors_init_insertion_ivars
          end
        end

        def __find_neighbors
          my_name = @name
          _reinit_stream
          least_greater_name = nil
          while fly = @stream.gets
            name = fly.dereference :name
            case name <=> my_name
            when -1 ; greatest_lesser_name = name
            when  0 ; exact = fly ; break
            when  1 ; least_greater_name ||= name
            end
          end
          [ greatest_lesser_name, exact, least_greater_name ]
        end

        def __when_exact_match_fly_resolve_insertion_ivars

          _has_force = send @_has_force  # (a bit of extra poka-yoke)

          if _has_force
            __via_exact_match_init_insertion_ivars  # #cov3.3
          else
            __when_name_collision
          end
        end

        def __via_exact_match_init_insertion_ivars
          o = remove_instance_variable :@exact_match_fly
          @insertion_range = o.line_start .. o.end_pos
          @reference_meaning = o
          _same
        end

        def __after_greatest_lesser_name_init_insertion_ivars
          @reference_meaning = _find_first_flyweight_with_name @greatest_lesser_name
          d = @reference_meaning.next_line_start_pos
          @insertion_range = d ... d
          _same
        end

        def __before_least_greater_name_init_insertion_ivars
          @reference_meaning = _find_first_flyweight_with_name @least_greater_name
          d = @reference_meaning.next_line_start_pos
          @insertion_range = d ... d
          _same
        end

        def _same
          @mutable_s = @reference_meaning.mutable_whole_string
          ACHIEVED_  # convenince
        end

        def _find_first_flyweight_with_name s
          _reinit_stream
          @stream.flush_until_detect do |ent|
            s == ent.dereference( :name )
          end
        end

        def _reinit_stream
          @stream = @entity_stream_by.call
          NIL
        end

        def __when_no_neighbors_init_insertion_ivars

          # ~(  # #here2
          d = 1
          @_name_range = d ... ( d + @name.length )
          d = @_name_range.end + 3  # " : ".length
          @_value_range = d ... ( d + @value.length )
          # ~)

          @new_line = " #{ @name } : #{ @value }\n"
          @mutable_s = @fallback_mutable_string
          @mutable_s[ @mutable_s.length, 0 ] = "#"  # because MEH
          @insertion_range = @mutable_s.length ... @mutable_s.length
          ACHIEVED_  # convenience
        end

        def __rewrite_string
          @new_line || __init_new_line  # :#here1
          @mutable_s[ @insertion_range ] = @new_line  # etc

          # -- new in :#history-A.1: hack an entity result per #spot2.3

          _n_r = remove_instance_variable :@_name_range
          _v_r = remove_instance_variable :@_value_range
          _s = remove_instance_variable( :@new_line ).freeze
          Here_::Flyweight__.via_this_data__ _v_r, _n_r, _s
        end

        def __init_new_line
          o = @reference_meaning
          o_x = o.line_start
          its_width_to_colon = o.colon_pos - o_x
          its_e2_width = o.colon_pos - o.name_range.end - 1
          its_e0 = o.mutable_whole_string[ o_x .. o.name_range.begin - 1 ]
          its_e0 = __sanitize_e0 its_e0
          e0 = "#{ its_e0 }#{
            SPACE_ * [ 0,
          ( its_width_to_colon - its_e2_width - @name.length - its_e0.length )
                   ].max
          }"
          e2 = SPACE_ * its_e2_width
          e4 = SPACE_ * ( o.value_range.begin - 1 - o.colon_pos )

          # ~(  # #here2
          d = e0.length
          @_name_range = d ... ( d + @name.length )
          d = @_name_range.end + e2.length + 2  # ":".length + 1
          @_value_range = d ... d + @value.length
          # ~)

          @new_line = "#{ e0 }#{ @name }#{ e2 }:#{ e4 }#{ @value }\n" ; nil
        end

        def __sanitize_e0 its_e0
          if C_STYLE_OPEN_COMMENT_RX_ =~ its_e0
            SPACE_ * its_e0.length
          else
            its_e0.gsub TRAILING_WHITESPACE_RX__, EMPTY_S_
          end
        end

        def __when_name_collision
          value = @exact_match_fly.dereference :value
          if value == @value
            __when_no_change
          else
            __when_will_not_clobber
          end
        end

        def __when_no_change
          maybe_send_event :error, :no_change do
            __build_no_change_event
          end
          UNABLE_
        end

        def __build_no_change_event
          build_not_OK_event_with :no_change,
              :name, @name, :value, @value do |y, o|
            y << "#{ lbl o.name } is already set to #{ val o.value }."
          end
        end

        def __when_will_not_clobber
          maybe_send_event :error, :name_collision do
            __build_name_collision_event
          end
          UNABLE_
        end

        def __build_name_collision_event
          build_not_OK_event_with :name_collision,
              :name, @name,
              :existing_value, @exact_match_fly.dereference( :value ),
              :replacement_value, @value do |y, o|

            buff = ""
            buff << "cannot set #{ component_label o.name }"
            buff << " to #{ mixed_primitive o.replacement_value }"
            buff << ". it is already set to #{ mixed_primitive o.existing_value }"
            y << buff
          end
        end

        # --
        #
        # (these used to happen in `normalize_by` meta-associations in the
        # action definition; but we have moved these normalizations inward
        # so that they get re-used for internal API calls..)

        def __normalize_name_and_value

          _ok = _normalize :@name, :Name
          _ok and _normalize :@value, :Value
        end

        def _normalize ivar, const
          _x = remove_instance_variable ivar
          _sym = ivar[ 1..-1 ].intern  # meh
          _qkn = Common_::QualifiedKnownness.via_value_and_symbol _x, _sym
          _f = Here_::Magnetics_::NormalizedKnownness_via_QualifiedKnownness.const_get const, false
          kn = _f[ _qkn, & @listener ]
          if kn
            instance_variable_set ivar, kn.value_x
            ACHIEVED_
          else
            self._COVER_ME__just_a_reminder__failures_like_these_are_not_covered__
          end
        end

        # --

        def maybe_send_event * a, & p
          @listener.call( * a, & p )
          NIL
        end

        def build_not_OK_event_with * a, & p
          Common_::Event.inline_not_OK_via_mutable_iambic_and_message_proc a, p
        end

        def __FALSE
          FALSE
        end

        def __TRUE
          TRUE
        end

        C_STYLE_OPEN_COMMENT_RX_ = /\A[ \t]*\/\*/
        TRAILING_WHITESPACE_RX__ = /[ \t]+\z/

      # -
    end
  end
end
# #pending-rename: perhaps to anything else
# #history-A.1: minor modernification of style - leading underscores of method names
