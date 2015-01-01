module Skylab::BeautySalon

  class Models_::Search_and_Replace

    module Actors_::Build_file_scan

      class Models__::Interactive_File_Session

        class << self

          def producer_via_iambic x_a
            ok = nil
            x = Producer__.new do
              ok = process_iambic_stream_fully iambic_stream_via_iambic_array x_a
            end
            ok && x
          end
        end

        class Producer__

          Callback_::Actor.methodic self, :simple, :properties,

            :property, :ruby_regexp,
            :ignore, :property, :grep_extended_regexp_string,
            :ignore, :property, :do_highlight,
            :property, :max_file_size_for_multiline_mode,
            :property, :on_event_selectively

          def initialize
            super
            @max_file_size_for_multiline_mode ||= DEFAULT_MAX_FILE_SIZE_FOR_MULTIINE_MODE__
            @rx_opts = BS_.lib_.basic::Regexp.options_via_regexp @ruby_regexp
          end

          DEFAULT_MAX_FILE_SIZE_FOR_MULTIINE_MODE__ = 463296

          # as a stab in the dark we arrived at this number by taking our
          # largest current file (~1.8K SLOC) and multiplying it arbitrarily
          # by 8, which gets you to around 15K lines of platform code.
          # what the "right" cutoff point is totally system dependent and not
          # really of interest to us here, which is why we take this field
          # a parameter and provide this just as a last-line catchall.


          def produce_file_session_via_ordinal_and_path d, path
            stat = ::File.stat path  # noent meh
            if stat.size <= @max_file_size_for_multiline_mode
              when_multiline_OK d, path
            elsif @rx_opts.is_multiline
              when_multiline_regexp_and_multiline_not_OK
            else
              when_single_line d, path
            end
          end

          def when_multiline_OK d, path
            es = Self_::String_Edit_Session_.new(
              ::File.open( path, READ_MODE_ ).read,  # noent meh
              @ruby_regexp,
              @on_event_selectively )

            es.set_file_metadata d, path
            es
          end
        end

        Self_ = self
      end
    end
  end
end
