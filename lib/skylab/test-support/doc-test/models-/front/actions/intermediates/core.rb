module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Intermediates < Action_

        edit_entity_class :promote_action,

          :desc, -> y do
            y << "generate #{ val Home_::Init.test_support_filenames.first } files"
          end,

          :after, :recursive,

          :inflect,
            :verb, 'generate',
            :noun, 'intermedate file',

          :flag, :property, :preview,

          :flag, :property, :dry_run,

          :property, :downstream,

          :required,

          :description, -> y do
            y << "a spec file that needs a corresponding test-support file"
          end,

          :ad_hoc_normalizer, -> arg, & oes_p do

            if arg.is_known && arg.value_x
              Home_.lib_.basic::Pathname.normalization.new_with(
                :absolute, :downward_only,
                :no_single_dots,
                :no_dotfiles ).normalize_argument arg, & oes_p
            else
              arg
            end
          end,
          :property, :path


        def normalize
          _ok = super
          _ok and my_normalize
        end

        def my_normalize
          via_properties_init_ivars
          ACHIEVED_
        end

        def produce_result

          @FS = DocTest_::Idioms_::Filesystem.new( & handle_event_selectively )

          @tmpl = DocTest_::Idioms_::Template.new(
            DocTest_::Output_Adapters_::Quickie.templates_path,
            Shared_Resources_.new )

          ok = @FS.file_must_exist @path

          ok and begin

            @dirname = ::File.dirname @path

            pn = @FS.find_testsupport_file_upwards @dirname
            pn and begin
              @ts_path = pn.to_path
              via_ts_path
            end

          end
        end

        def via_ts_path

          if "#{ @dirname }#{ FILE_SEP_ }" == @ts_path[ 0, @dirname.length + 1 ]
            via_attempt_to_find_second_path
          else
            via_one_path
          end
        end

        def via_one_path

          swap = @ts_path
          @ts_path = "#{ @path }/hack-no-see"
          @ts_path_ = swap

          via_two_paths
        end

        def via_attempt_to_find_second_path

          @dirname_ = ::File.dirname ::File.dirname @ts_path

          pn = @FS.find_testsupport_file_upwards @dirname_
          pn and begin
            @ts_path_ = pn.to_path
            via_two_paths
          end

        end

        def via_two_paths

          current = ::File.dirname @ts_path_
          dirname = ::File.dirname ::File.dirname @ts_path

          if current == dirname
            no_intermediates
          else
            via_current_and_dirname current, dirname
          end
        end

        def no_intermediates
          maybe_send_event :info, :nothing_to_do do
            build_neutral_event_with :nothing_to_do,
                :upper_TS_path, @ts_path_,
                :lower_TS_path, @ts_path do | y, o |

              y << "no intermediates to make between #{ pth o.upper_TS_path } #{
                }and #{ pth o.lower_TS_path }"
            end
          end
        end

        def via_current_and_dirname current, dirname

          work_a = dirname[ current.length + 1 .. -1 ].split FILE_SEP_

          job = Job__.new( @dry_run, @preview, @downstream, @tmpl, @FS,
                          & handle_event_selectively )

          p = -> do
            if work_a.length.zero?
              p = EMPTY_P_
              nil
            else
              job.new current, work_a.shift
            end
          end

          _st = Callback_.stream do
            p[]
          end

          via_job_stream _st
        end

        def via_job_stream st
          ok = true
          job = st.gets
          count = 0
          while job
            count += 1
            ok = job.execute
            ok or break
            job = st.gets
          end
          report_via_count count
        end

        def report_via_count d
          @on_event_selectively.call :info, :finished do
            Callback_::Event.inline_with :finished,
                :number_of_files, d,
                :ok, ( d.nonzero? ? true : false ) do | y, o |

              d_ = o.number_of_files
              y << "(generated #{ d_ } file#{ s d_ })"
            end
          end
        end

        class Job__

          def initialize * a, & oes_p
            @is_dry, @is_preview, @downstream, @tmpl, @FS = a
            @on_event_selectively = oes_p
            freeze
          end

          def new * a
            otr = dup
            otr.init a
            otr
          end

          protected def init a
            @current, @dir = a
            nil
          end

          def execute

            @existent_path = ::File.join @current, @FS.test_support_file
            @desired_path = ::File.join @current, @dir, @FS.test_support_file

            @tree = Home_.lib_.system.filesystem.hack_guess_module_tree(
              :path, @existent_path,
              & @on_event_selectively )

            @tree and via_tree
          end

        private

          def via_tree
            i_a = @tree.children.first.value_x.dup
            const_sym = Callback_::Name.via_slug( @dir ).as_const
            i_a.push const_sym
            _lines = Self_::View_Controller__.new( i_a, @tmpl ).execute
            via_line_stream _lines
          end

          def via_line_stream st

            resolve_down_IO

            d = 0
            d_ = 0
            line = st.gets
            while line
              d_ += 1
              d += ( @down_IO.write line )
              line = st.gets
            end

            if @did_open
              @down_IO.close
            end

            @on_event_selectively.call :info, :wrote do

              DocTest_::Output_Adapter_.event_for_wrote.new_with(
                :is_known_to_be_dry, @is_dry,
                :bytes, d,
                :line_count, d_,
                :ok, true )  # important - batch job will stop early without this

            end  # result of client can stop the job here
          end

          def resolve_down_IO

            @did_open = false
            @down_IO = if @is_preview
              @downstream
            else

              @on_event_selectively.call :info, :writing do
                Callback_::Event.inline_neutral_with :writing,
                  :path, @desired_path
              end

              if @is_dry
                Home_.lib_.IO.dry_stub_instance
              else
                @did_open = true
                ::File.open @desired_path, 'w'
              end
            end
          end
        end

        Self_ = self
      end
    end
  end
end
