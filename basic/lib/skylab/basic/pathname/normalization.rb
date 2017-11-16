module Skylab::Basic

  module Pathname

    class Normalization

        # do not let this seep into the scope of [#sy-004]. do not use FS here

        Attributes_actor_[ self ]

        def initialize & p

          if p
            @listener = p
          end

          @_do_freeze = true
          @absolute_is_OK = true
          @content_validation_is_required = false
          @content_validation_is_activated = false
          @disallow_h = nil
          @relative_is_OK = true
        end

      private

        def absolute=
          @relative_is_OK = false
          KEEP_PARSING_
        end

        def relative=
          @absolute_is_OK = false
          KEEP_PARSING_
        end

        def downward_only=
          add_content_validation_against :dot_dot
          KEEP_PARSING_
        end

        def no_single_dots=
          add_content_validation_against :single_dot
          KEEP_PARSING_
        end

        def no_dotfiles=
          add_content_validation_against :dot_file
          KEEP_PARSING_
        end

        def qualified_knownness=
          @_do_freeze = false
          @qualified_knownness = @_argument_scanner_narrator_.gets_one
          KEEP_PARSING_
        end

        def as_attributes_actor_normalize
          if @_do_freeze
            freeze
          end
          KEEP_PARSING_
        end

        def initialize_copy _otr_
          @bad_box = @s_a = nil  # never carry these over for now
          if @disallow_h
            @disallow_h = @disallow_h.dup
          end
        end

        def add_content_validation_against i
          if ! @content_validation_is_activated
            activate_content_validation
          end
          @disallow_h[ i ] = true ; nil
        end

        def activate_content_validation
          @content_validation_is_activated = true
          @content_validation_is_required = true
          @disallow_h = {}
        end

      public

        def normalize_value x, & p

          normalize_qualified_knownness(
            Common_::QualifiedKnownKnown.via_value_and_symbol( x, :path ),
            & p )
        end

        def normalize_qualified_knownness qkn, & p
          otr = dup
          otr.init_copy qkn, & p
          otr.execute
        end

        protected def init_copy qkn, & p
          @qualified_knownness = qkn
          p and @listener = p
          nil
        end

        def execute
          @value = @qualified_knownness.value
          @value and via_value_x
        end

      private

        def via_value_x
          @md = RX__.match @value
          if @md
            via_md
          else
            when_did_not_match
          end
          @result
        end

        def when_did_not_match
          nope :path_cannot_contain_repeated_separators
        end

        def via_md
          @body_s = @md[ :body ]
          ok = validate_absolute_and_relative_and_empty
          ok && maybe_validate_content
        end

        def validate_absolute_and_relative_and_empty
          if @md[ :abs ]
            @is_absolute = true
            if @absolute_is_OK
              PROCEDE_
            else
              when_absolute
            end
          elsif ! @body_s
            when_empty
          elsif @relative_is_OK
            @is_absolute = false
            PROCEDE_
          else
            when_relative
          end
        end

        _SEP = ::Regexp.escape ::File::SEPARATOR
        RX__ = %r<\A
          (?<abs>#{ _SEP })?
          (?<rest>
             (?<body>
               [^#{ _SEP }]+
                 (?: #{ _SEP } [^#{ _SEP }]+ )*
             )
             (?<trailing> #{ _SEP })?
          )?
        \z>x

        def when_absolute
          nope :path_cannot_be_absolute
        end

        def when_relative
          nope :path_cannot_be_relative
        end

        def when_empty
          nope :path_cannot_be_empty
        end

        def maybe_validate_content
          if @content_validation_is_required
            validate_content
          else
            accept_arg_as_is
          end
        end

        def validate_content
          if @body_s
            via_body_string_validate_content
          else
            # this should only ever occur with the root path
            accept_arg_as_is
          end
        end

        def via_body_string_validate_content
          disallow_h = @disallow_h
          @bad_box = nil
          @s_a = @body_s.split ::File::SEPARATOR
          @s_a.each_with_index do |s, d|
            md = PART_RX__.match s
            if ! md[ :other ]
              if md[ :single_dot ]
                if disallow_h[ :single_dot ]
                  add_bad d, :single_dot
                end
              elsif md[ :dot_dot ]
                if disallow_h[ :dot_dot ]
                  add_bad d, :dot_dot
                end
              elsif md[ :dot_file ]
                if disallow_h[ :dot_file ]
                  add_bad d, :dot_file
                end
              end
            end
          end
          if @bad_box
            when_bad_box
          else
            accept_arg_as_is
          end
        end

        PART_RX__ = /\A(?:
          (?<single_dot> \. ) |
          (?<dot_dot> \.\. ) |
          (?<dot_file> \. .+ ) |
          (?<other> .+ )
        )\z/x

        def add_bad d, i
          @bad_box ||= Common_::Box.new
          @bad_box.touch_array_and_push i, d
          nil
        end

        def when_bad_box
          nope :"path_cannot_contain_#{ @bad_box.first_key }"
            # for now we don't report every issue
        end

        # the above generates:
        #   + `path_cannot_contain_single_dot`
        #   + `path_cannot_contain_contain_dot_dot`
        #   + `path_cannot_contain_contain_dot_file`

        def accept_arg_as_is
          @result = @qualified_knownness.to_knownness
          ACHIEVED_
        end

        def nope terminal_channel_symbol

          maybe_send_event :error, :invalid_property_value do

            build_argument_error_event_with_(

              terminal_channel_symbol,
              :path, @value,
              :prop, @qualified_knownness.association

           ) do | y, o |

              s_a = o.terminal_channel_symbol.id2name.split UNDERSCORE_
              s_a.shift

              y << "#{ par o.prop } #{ s_a * SPACE_ } - #{ ick o.path }"
            end
          end
          # (result from above is unreliable)
          @result = UNABLE_
          UNABLE_
        end

        include Simple_Selective_Sender_Methods_  # instead of "entity"'s
          # event-building stuff, just for consistency within the library

      # ==
      # ==
    end
  end
end
