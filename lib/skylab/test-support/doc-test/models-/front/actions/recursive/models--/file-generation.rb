module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive

        class Models__::File_Generation

          # it may seem strange to model as a (er..) model something that
          # sounds like it should be an actor (for what does an object by
          # this name do other than generate files?). we do it as a model
          # and not as an actor because it's easiest for us to model this
          # as a decidedly mutable data structure so that parameter funcs
          # can mutate the request progressively on top of each other.

          class << self
            def new * x_a, & oes_p
              ok = true
              x = super() do
                @on_event_selectively = oes_p
                ok = process_iambic_stream_fully iambic_stream_via_iambic_array x_a
              end
              ok and x
            end
          end

          def initialize & p
            @errstream = @force = nil
            instance_exec( & p )
            @template_variable_box = nil
            freeze
          end

          include Callback_::Actor.methodic_lib.iambic_processing_instance_methods

        private

          def is_dry=
            @is_dry = iambic_property
            KEEP_PARSING_
          end

          def downstream=
            @errstream = iambic_property
            KEEP_PARSING_
          end

          def force_is_present=
            @force_is_present = iambic_property
            KEEP_PARSING_
          end

          def kernel=
            @kernel = iambic_property
            KEEP_PARSING_
          end

        public

          def new manifest_entry
            otr = dup
            otr.init manifest_entry
            otr
          end

          protected def init manifest_entry
            @manifest_entry = manifest_entry
            nil
          end

          def members
            [ :manifest_entry, :output_path ]
          end

          attr_reader :manifest_entry, :output_path

          def execute
            ok = pre_normalize
            ok &&= apply_any_parameters
            ok && generate
          end

        private

          # ~ pre-normalize

          def pre_normalize

            @manifest_entry_absolute_path = @manifest_entry.get_absolute_path
            ok = via_manifest_entry_absolute_path_resolve_test_dir_pathname
            ok && via_test_dir_pathname_resolve_output_path
          end

          def via_manifest_entry_absolute_path_resolve_test_dir_pathname

            @test_dir_pn = TestSupport_._lib.system.filesystem.walk(
              :start_path, ::File.dirname( @manifest_entry_absolute_path ),
              :filename, TEST_DIR_FILENAME_,
              :ftype, DIR_FTYPE_,
              :max_num_dirs_to_look, -1,
              :property_symbol, :manifest_entry_path_dirname,
              :on_event_selectively, @on_event_selectively )

            @test_dir_pn ? ACHIEVED_ : UNABLE_
          end

          DIR_FTYPE_ = 'directory'.freeze

          def via_test_dir_pathname_resolve_output_path

            test_dir_path = @test_dir_pn.to_path

            sidesystem_path_length =
               test_dir_path.length - SEP_LENGTH_ - TEST_DIR_FILENAME_.length

            _sidesystem_abspath = @manifest_entry_absolute_path[ 0, sidesystem_path_length ]

            sidesys_relpath = @manifest_entry_absolute_path[ sidesystem_path_length + SEP_LENGTH_ .. -1 ]

            if sidesys_relpath.include? FILE_SEP_
              dirname = remove_trailing_dashes_from_pathparts ::File.dirname sidesys_relpath
              basename = ::File.basename sidesys_relpath
            else
              basename = sidesys_relpath
            end

            _testfile_basename = testfile_basename_via_basename basename

            part_a = [ _sidesystem_abspath, TEST_DIR_FILENAME_ ]
            dirname and part_a.push dirname
            part_a.push _testfile_basename

            @output_path = ::File.join( * part_a )

            ACHIEVED_
          end  # :[#bs-026]. this method is a case study

          def remove_trailing_dashes_from_pathparts sidesys_relpath

            _upstream_parts = sidesys_relpath.split FILE_SEP_

            _downstream_parts = _upstream_parts.map do | s |
              s.gsub Callback_::Name::TRAILING_DASHES_RX__, EMPTY_S_  # ick/meh
            end

            _downstream_parts.join FILE_SEP_
          end

          def testfile_basename_via_basename basename
            pn = ::Pathname.new basename
            ext  = pn.extname
            stem = pn.sub_ext( EMPTY_S_ ).to_path
            "#{ stem }#{ TestSupport_::Init.test_file_basename_suffix_stem }#{ ext }"
          end

          SEP_LENGTH_ = FILE_SEP_.length

          # ~ parameter functions

          def apply_any_parameters
            @parameter_a = @manifest_entry.tagging_a
            if @parameter_a
              ok = via_parameter_array_prepare
            else
              ok = true
            end
            ok
          end

          def via_parameter_array_prepare
            ok = true
            @parameter_a.each do | ast |
              _i = ast.normal_name_symbol
              p = Callback_::Autoloader.const_reduce [ _i ], Parameter_Functions__ do | * i_a, & ev_p |
                when_parameter_function_not_found i_a, & ev_p
              end
              ok = if p
                p.call self, ast.value_x, & @on_event_selectively
              else
                UNABLE_
              end
              ok or break
            end
            ok
          end

          def when_parameter_function_not_found i_a, & ev_p  # #todo:cover
            @on_event_selectively.call( * i_a ) do
              Recursive_::Actors__::Build_unrecognized_parameter_event[ ev_p[], Parameter_Functions__ ]
            end
          end

          # ~ public API for parameter functions

        public

          def receive_output_path x
            if x
              @output_path = x
              ACHIEVED_
            else
              x
            end
          end

          def set_template_variable sym, x
            @template_variable_box ||= Callback_::Box.new
            @template_variable_box.set sym, x
            nil
          end

        private

          # ~ generate

          def generate

            if @errstream
              maybe_send_event :info, :current_output_path do
                TestSupport_._lib.event_lib.inline_neutral_with(
                  :current_output_path, :path, @output_path )
              end
            end

            x = @kernel.call :generate,

              * ( :dry_run if @is_dry ),

              * ( :force if @force_is_present ),

              :template_variable_box, @template_variable_box,

              :line_downstream, @errstream,  # nil ok

              :output_path, ( @output_path if ! @errstream ),

              :upstream_path, @manifest_entry_absolute_path,

              :output_adapter, :quickie,
              :on_event_selectively, @on_event_selectively

            if x.nil?

              # when the above API call succeeds, the result is the result
              # of the last callback, whose event may be informational and
              # hence result in nil above by default. we upgrade this here
              # so this isn't mis-read as a failure (covered) with a side-
              # effect that you cannot meaningfully result in nil, which is
              # no big deal

              ACHIEVED_
            else
              x
            end
          end

          # ~ support

          def maybe_send_event * i_a, & ev_p
            @on_event_selectively[ * i_a, & ev_p ]
          end

          class Parameter_Function_

            class << self
              def call gen, arg_x, & oes_p
                new( gen, arg_x, & oes_p ).execute
              end
            end

            def initialize gen, arg_x, & oes_p
              @generation = gen
              @value_x = arg_x
              @on_event_selectively = oes_p
            end

            def execute
              _ok = normalize
              _ok && flush
            end

          private

            def build_unrecognized_param_arg ok_x_a
              TestSupport_._lib.entity.properties_stack.
                build_extra_properties_event(
                  [ @value_x ],
                  ok_x_a,
                  "parameter argument" )
            end

            def maybe_send_event * i_a, & oes_p
              @on_event_selectively.call( * i_a, & oes_p )
            end
          end

          module Parameter_Functions__
            Callback_::Autoloader[ self, :boxxy ]
          end

          Self_ = self
        end
      end
    end
  end
end
