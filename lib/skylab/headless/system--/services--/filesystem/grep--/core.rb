module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Grep__  # see [#173]. this particular node models the command itself

        class << self

          def mixed_via_iambic x_a

            new do
              process_iambic_fully x_a
            end.mixed_result

          end
        end

        Callback_::Actor.methodic self, :simple, :properties,

          :iambic_writer_method_to_be_provided, :ignore_case,

          :iambic_writer_method_to_be_provided, :do_ignore_case,

          :iambic_writer_method_to_be_provided, :path,

          :iambic_writer_method_to_be_provided, :paths,

          :properties, :ruby_regexp, :on_event_selectively, :as_normal_value

        def initialize
          @ignore_case_is_known = false
          @unescaped_path_s_a = nil
          super
          @on_event_selectively ||= EVENTLESS_LISTENER__
          @as_normal_value ||= IDENTITY_
        end

      private

        def ignore_case=
          @do_ignore_case = nil
          @ignore_case_is_known = true
          @do_ignore_case = true
        end

        def do_ignore_case=
          @ignore_case_is_known = true
          @do_ignore_case = iambic_property
        end

        def path=
          ( @unescaped_path_s_a ||= [] ).clear.push iambic_property
        end

        def paths=
          @unescaped_path_s_a = iambic_property
        end

      public def mixed_result
          opts = Headless_::Lib_::Bsc_[]::Regexp.options_via_regexp @ruby_regexp
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
            get_busy
          end
        end

        def no_support_for i_a
          @on_event_selectively.call :error, :regexp_option_not_supported do
            Headless_::Lib_::Event_lib[].
              inline_not_OK_with :non_convertible_regexp_options,
                :option_symbols, i_a, :regexp, @ruby_regexp
          end
        end

        def get_busy

          shellwords = Headless_::Lib_::Shellwords[]

          y = [ 'grep', '-E' ]
          if @do_ignore_case
            y.push '--ignore-case'
          end
          y.push shellwords.escape @ruby_regexp.source

          if @unescaped_path_s_a
            @unescaped_path_s_a.each do |path|
              y.push shellwords.escape path
            end
          end

          @command_string = y * SPACE_

          @as_normal_value[ self ]
        end

      public

        def to_scan
          @command_string and via_command_string_produce_scan
        end

        def string
          @command_string
        end

      private

        def via_command_string_produce_scan
          produce_scan_via_command_string @command_string
        end

      public

        def produce_scan_via_command_string command_string
          thread = nil
          p = -> do
            _, o, e, thread = Headless_::Library_::Open3.popen3 command_string
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
          Callback_.scan do
            p[]
          end.with_signal_handlers :release_resource, -> do
            if thread && thread.alive?
              thread.exit
            end
            ACHIEVED_
          end
        end

        def when_system_error err_s
          @on_event_selectively.call :error, :system_call_error do
            Headless_::Lib_::Event_lib[].inline_not_OK_with :system_call_error,
              :message, err_s, :error_category, :system_call_error
          end
          UNABLE_
        end

        EVENTLESS_LISTENER__ = -> i, * do
          if :info != i
            UNABLE_
          end
        end

      end
    end
  end
end
