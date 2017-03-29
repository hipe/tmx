module Skylab::System

  module Filesystem

    class Walk  # :[#176]

      # was [#ts-019], then [#st-007]. was once tagged [#cu-003]
      # ->

        class << self

          def build_resource_not_found_event start_path, file_pat_s_or_s_a, num_dirs_looked

            Build_resource_not_found_event__[ start_path, file_pat_s_or_s_a, num_dirs_looked ]
          end
        end  # >>

        Attributes_actor_.call( self,
          start_path: nil,
          filename: nil,
          ftype: nil,
          max_num_dirs_to_look: nil,
          prop: nil,
          property_symbol: nil,
          do_lock: nil,
          filesystem: nil,
        )

        include Common_::Event::ReceiveAndSendMethods

        def initialize & oes_p

          @argument_path_might_be_target_path = nil
          @do_lock = false
          @ftype = nil
          @on_event_selectively = oes_p
          @prop = nil
          @property_symbol = nil
        end

        def as_attributes_actor_normalize
          @filesystem ||= Home_.services.filesystem
          KEEP_PARSING_
        end

      private

        def argument_path_might_be_target_path=
          @argument_path_might_be_target_path = true
          ACHIEVED_
        end

      public

        def find_any_nearest_surrounding_path  # :+#public-API
          execute
        end

        def execute
          __init_ivars
          __work
        end

      private

        def __init_ivars
          if Path_looks_relative_[ @start_path ]
            @start_path = @filesystem.expand_path @start_path
          end
          nil
        end

        def __work
          st, e = __stat_and_stat_error
          if st

            if DIRECTORY_FTYPE == st.ftype

              __find_any_nearest_file_when_start_path_exist

            elsif __maybe_determine_if_argument_path_is_target_path st

              @__result_for_when_argument_path_is_target_path

            else

              __when_start_directory_is_not_directory st
            end
          else
            __when_start_directory_does_not_exist e
          end
        end

        def __stat_and_stat_error
          @filesystem.stat @start_path
        rescue ::Errno::ENOENT => e
          [ nil, e ]
        end

        def __maybe_determine_if_argument_path_is_target_path st

          @argument_path_might_be_target_path &&
            FILE_FTYPE == st.ftype &&
              __determine_if_argument_path_is_target_path
        end

        def __determine_if_argument_path_is_target_path

          tgt = "#{ ::File::SEPARATOR }#{ @filename }"
          d = tgt.length

          if tgt == @start_path[ -d .. -1 ]

            @__result_for_when_argument_path_is_target_path =
              @start_path[ 0 ... -d ]

            true
          else
            false
          end
        end

        def __when_start_directory_is_not_directory st

          maybe_send_event :error, :start_directory_is_not_directory do

            _ = build_not_OK_event_with(
              :start_directory_is_not_directory,
              :start_path, @start_path,
              :ftype, st.ftype,
              :prop, prp,
            )
            _
          end

          UNABLE_
        end

        def __when_start_directory_does_not_exist e

          maybe_send_event :error, :start_directory_is_not_directory do

            _ = build_not_OK_event_with(
              :start_directory_does_not_exist,
              :start_path, @start_path,
              :exception, e,
              :prop, prp,
            )
            _
          end

          UNABLE_
        end

        def __find_any_nearest_file_when_start_path_exist

          count = 0

          continue_searching = if -1 == @max_num_dirs_to_look
            NILADIC_TRUTH_
          else
            -> { count < @max_num_dirs_to_look }
          end

          path = @start_path

          while continue_searching[]
            count += 1
            try = ::File.join path, @filename

            if @filesystem.exist? try
              found_path = try
              surrounding_path = path
              break
            end
            path_ = ::File.dirname path
            path_ == path and break  # we've reached the top (root path)
            path = path_
          end

          if found_path
            __found found_path, surrounding_path
          else
            __when_resource_not_found count
          end
        end

        def __found found_path, surrounding_path

          kn = Home_::Filesystem::Normalizations::Upstream_IO.via(
            :path, found_path,
            :must_be_ftype, ( @ftype || :FILE_FTYPE ),
            :do_lock_file, @do_lock,
            :filesystem, @filesystem,
            & @on_event_selectively )

          if kn
            if @do_lock
              ThisTuple___[ kn.value_x, surrounding_path ]
            else
              surrounding_path
            end
          else
            yes
          end
        end

        ThisTuple___ = ::Struct.new :locked_IO, :surrounding_path  # experimental

        def __when_resource_not_found count

          maybe_send_event :error, :resource_not_found do
            __build_resource_not_found_event count
          end

          UNABLE_
        end

        def __build_resource_not_found_event count
          Build_resource_not_found_event__[ @start_path, @filename, count ]
        end

        def prp
          @prop or bld_property
        end

        def bld_property

          sym = @property_symbol || :path

          Home_.lib_.fields::SimplifiedName.new sym do end
        end

        Build_resource_not_found_event__ = -> start_path, file_pat_s_or_s_a, num_dirs_looked do

          Common_::Event.inline_not_OK_with(
            :resource_not_found,
            :start_path, start_path,
            :file_pattern_string_or_array, file_pat_s_or_s_a,
            :num_dirs_looked, num_dirs_looked,

          ) do | y, o |

            if o.num_dirs_looked.zero?
              y << "no directories were searched."
            else
              if 1 < o.num_dirs_looked
                d = o.num_dirs_looked - 1
                _xtra = " or #{ d } dir#{ s d } up"
              end
              y << "#{ ick_mixed o.file_pattern_string_or_array } #{
                }not found in #{ pth o.start_path }#{ _xtra }"
            end
          end
        end

        # <-

      Walk_ = self
    end
  end
end
