module Skylab::System

  class Services___::Filesystem

    class Bridges_::Grep  # see [#173]. this particular node models the command itself

      # ->

        class << self

          def for_mutable_args_ x_a, & oes_p

            new do

              if oes_p
                accept_selective_listener_proc oes_p
              end

              process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a

            end.mixed_result
          end
        end  # >>

        Callback_::Actor.methodic( self, :simple, :properties,

          :polymorphic_writer_method_to_be_provided, :property, :ignore_case,

          :polymorphic_writer_method_to_be_provided, :property, :do_ignore_case,

          :polymorphic_writer_method_to_be_provided, :property, :path,

          :polymorphic_writer_method_to_be_provided, :property, :paths,

          :properties,
            :grep_extended_regexp_string,
            :ruby_regexp,
            :when_curry,
        )

        def initialize
          @grep_extended_regexp_string = nil
          @ignore_case_is_known = false
          @unescaped_path_s_a = nil
          super
          @on_event_selectively ||= EVENTLESS_LISTENER__
          @when_curry ||= IDENTITY_
        end

        def accept_selective_listener_proc x
          @on_event_selectively = x
          NIL_
        end

      private

        def ignore_case=
          @do_ignore_case = nil
          @ignore_case_is_known = true
          @do_ignore_case = true
          KEEP_PARSING_
        end

        def do_ignore_case=
          @ignore_case_is_known = true
          @do_ignore_case = gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def path=
          ( @unescaped_path_s_a ||= [] ).clear.push gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def paths=
          @unescaped_path_s_a = gets_one_polymorphic_value
          KEEP_PARSING_
        end

      public def mixed_result

          if @grep_extended_regexp_string
            via_grep_regexp_mixed_result
          else
            via_ruby_regexp_mixed_result
          end
        end

        def via_ruby_regexp_mixed_result
          opts = Home_.lib_.basic::Regexp.options_via_regexp @ruby_regexp
          xtra_i_a = nil
          if opts.is_multiline
            ( xtra_i_a ||= [] ).push :MULTILINE
          end
          if opts.is_extended
            ( xtra_i_a ||= [] ).push :EXTENDED
          end
          if xtra_i_a
            no_support_for xtra_i_a.freeze
          else
            if ! @ignore_case_is_known
              @do_ignore_case = opts.is_ignorecase
            end
            @grep_regexp_guess = @ruby_regexp.source
            get_busy
          end
        end

        def no_support_for i_a
          @on_event_selectively.call :error, :regexp_option_not_supported do
            Callback_::Event.
              inline_not_OK_with :non_convertible_regexp_options,
                :option_symbols, i_a, :regexp, @ruby_regexp
          end
        end

        def via_grep_regexp_mixed_result
          if ! @ignore_case_is_known
            @do_ignore_case = false
          end
          @grep_regexp_guess = @grep_extended_regexp_string
          get_busy
        end

        def get_busy

          shellwords = Home_.lib_.shellwords

          y = [ 'grep', '-E' ]
          if @do_ignore_case
            y.push '--ignore-case'
          end
          y.push shellwords.escape @grep_regexp_guess

          if @unescaped_path_s_a
            @unescaped_path_s_a.each do |path|
              y.push shellwords.escape path
            end
          end

          @command_string = y * SPACE_

          @when_curry[ self ]
        end

      public

        def to_stream
          @command_string and via_command_string_produce_stream
        end

        def string
          @command_string
        end

      private

        def via_command_string_produce_stream
          produce_stream_via_command_string @command_string
        end

      public

        def produce_stream_via_command_string command_string

          thread = nil

          p = -> do
            _, o, e, thread = Home_.lib_.open3.popen3 command_string
            err_s = e.gets
            if err_s && err_s.length.nonzero?
              o.close
              p = -> { UNABLE_ }
              when_system_error err_s
            else
              p = -> do
                s = o.gets
                if s
                  s.chop!
                  s
                else
                  p = -> { s }
                  s
                end
              end
              p[]
            end
          end

          o = Callback_::Stream
          o.new(
            o::Resource_Releaser.new do
              if thread && thread.alive?
                thread.exit
              end
              ACHIEVED_
            end
          ) do
            p[]
          end
        end

        def when_system_error err_s
          @on_event_selectively.call :error, :system_call_error do
            Callback_::Event.inline_not_OK_with :system_call_error,
              :message, err_s, :error_category, :system_call_error
          end
          UNABLE_
        end

        EVENTLESS_LISTENER__ = -> i, * do
          if :info != i
            UNABLE_
          end
        end
        # <-
    end
  end
end
