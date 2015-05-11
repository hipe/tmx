module Skylab::System


    class Services___::Filesystem

      class Normalization__

        class Existent_Directory__ < self

          extend Common_Module_Methods_

          Entity_.call self do

            o :iambic_writer_method_name_suffix, :'='

            def create_if_not_exist=
              @do_create_if_not_exist = true
            end

            def path=
              @ready_to_execute = true
              @path_x = iambic_property
            end

            o :properties,

              :on_event_selectively,

              :is_dry_run,
              :max_mkdirs
          end

          def initialize & p
            @do_create_if_not_exist = nil
            @is_dry_run = false
            @max_mkdirs = 1
            @ready_to_execute = false
            instance_exec( & p )
          end

          def produce_mixed_result
            if @ready_to_execute
              execute  # an inline normalization
            else
              freeze  # a curried normalization
            end
          end

          def normalize_value path_x, & oes_p
            otr = dup
            otr.init :path, path_x, & oes_p
            otr.execute
          end

        protected

          def init * x_a, & oes_p
            @on_event_selectively = oes_p
            process_iambic_stream_fully iambic_stream_via_iambic_array x_a
            nil
          end

          def execute
            @path = if @path_x.respond_to? :to_path
              @path_x.to_path
            else
              @path_x
            end
            if path_exists_and_set_stat_and_stat_error @path
              via_stat_execute
            else
              when_no_stat  # in this file, a method whose name is prefixed
              # with `when_` signifies a result method: the result of the
              # method call is the result of this normalization
            end
          end

        private

          def via_stat_execute  # :+#public-API
            m_i = :"when_path_is_#{ @stat.ftype }"
            if respond_to? m_i
              send m_i
            else
              when_existent_path_is_strange
            end
          end

          public def when_path_is_directory
            result
          end

          def when_existent_path_is_strange
            maybe_send_event :error, :wrong_ftype do
              build_wrong_ftype_event_ @path, @stat, DIRECTORY_FTYPE
            end
          end

          def when_no_stat
            if ::Errno::ENOENT::Errno == @stat_e.errno
              if @do_create_if_not_exist
                try_create
              else
                maybe_send_event :error, :enoent do
                  via_no_ent_stat_error_build_event
                end
              end
            else
              maybe_send_event :error, :strange_stat_error do
                via_strange_stat_error_build_event
              end
            end
          end

          def try_create
            ok = can_create
            ok and work
            @result
          end

          def work
            System_.services.filesystem.file_utils_controller do |msg|
              maybe_send_event :info, :file_utils_event do
                Event_.wrap.file_utils_message msg
              end
            end.mkdir_p @path, noop: @is_dry_run  # result is array of argument paths
            @result = result
            PROCEDE_
          end

          def can_create  # assume @path does not exist

            stop_p = build_proc_for_stop_because_reached_max_mkdirs

            @num_dirs_needed_to_create = 1  # you need to create at least the tgt
            @curr_pn = ::Pathname.new ::File.expand_path @path

            while true  # assume current path does not exist

              if stop_p[]
                break next_i = :a_path_too_deep
              end

              parent_pn = @curr_pn.dirname

              # if parent_pn equals curr_pn then the root path doesn't exist
              # which is something we are not checking for & probably don't
              # need to except for a logic error sanity check.
              # # #todo - get rid of all hardcoded checks for '/' in univ.

              if path_exists_and_set_stat_and_stat_error parent_pn.to_path
                @pn = parent_pn
                break next_i = :via_stat_and_existent_pn_can_create
              end

              @num_dirs_needed_to_create += 1
              @curr_pn = parent_pn
            end
            send next_i
          end

          def a_path_too_deep
            @result = maybe_send_event :error, :path_too_deep do
              build_path_too_deep_event
            end
            UNABLE_
          end

          def build_proc_for_stop_because_reached_max_mkdirs
            if -1 == @max_mkdirs
              NILADIC_FALSEHOOD_
            else
              -> do
                @max_mkdirs < @num_dirs_needed_to_create
              end
            end
          end

          def via_stat_and_existent_pn_can_create
            m_i = :"can_create_when_#{ @stat.ftype }"
            if respond_to? m_i
              send m_i
            else
              when_strange_ftype
            end
          end

        public

          def can_create_when_directory
            PROCEDE_
          end

        private

          def when_strange_ftype
            @result = maybe_send_event :error, :wrong_ftype do
              via_stat_and_pn_build_wrong_ftype_event DIRECTORY_FTYPE
            end
            UNABLE_
          end

          def build_path_too_deep_event
            build_not_OK_event_with :path_too_deep,
                :path, @path, :necessary_path, @curr_pn.to_path,
                :max_mkdirs, @max_mkdirs,
                :necessary_mkdirs, @num_dirs_needed_to_create do |y, o|

              _tgt_path = o.path[ o.necessary_path.length + 1 .. -1 ]

              y << "cannot create #{ ick _tgt_path } because #{
               }would have to create at least #{ o.necessary_mkdirs } #{
                }directories, only allowed to make #{ o.max_mkdirs }, and #{
                 }#{ pth o.necessary_path } does not exist."
            end
          end

          def via_no_ent_stat_error_build_event
            Event_.wrap.exception @stat_e, :path_hack
          end

          def via_stat_and_pn_build_wrong_ftype_event expected_ftype_s
            build_not_OK_event_with :wrong_ftype,
                :actual_ftype, @stat.ftype,
                :expected_ftype, expected_ftype_s,
                :subject_path, @pn.to_path,
                :target_path, @path do |y, o|

              _tgt_path = o.target_path[ o.subject_path.length + 1 .. -1 ]

              y << "cannot create #{ _tgt_path } because #{
               }#{ pth o.subject_path } is #{ indefinite_noun o.actual_ftype }#{
                }, must be #{ indefinite_noun o.expected_ftype }"
            end
          end

          def via_strange_stat_error_build_event
            _ev = Event_.wrap.exception @stat_e, :path_hack
            i_a = _ev.to_iambic
            # (we used to add more members here, now we don't)
            Event_.inline_via_iambic_and_message_proc i_a, -> y, o do

              y << "cannot create #{ pth o.pathname } because #{
                }some parent path in it is #{ o.message_head.downcase }"

            end
          end

          def result
            System_.lib_.basic.trio(
              ( if @is_dry_run
                Mock_Dir__.new @path
              else
                ::Dir.new @path
              end ), true )
          end

          Mock_Dir__ = ::Struct.new :to_path

          NILADIC_FALSEHOOD_ = -> { false }
        end
      end
    end
end
