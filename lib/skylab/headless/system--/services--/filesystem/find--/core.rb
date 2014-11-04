module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Find__  # see [#171]. this particular node models the command itself

        class << self

          def mixed_via_iambic x_a
            new do
              process_iambic_fully x_a
              @x_a = @d = @x_a_length = nil  # #todo
            end.mixed_result
          end

          private :new
        end

        Callback_::Actor.methodic self, :simple, :properties,

          :iambic_writer_method_to_be_provided, :filename,

          :iambic_writer_method_to_be_provided, :filenames,

          :iambic_writer_method_to_be_provided, :freeform_query_infix,

          :iambic_writer_method_to_be_provided, :ignore_dirs,

          :iambic_writer_method_to_be_provided, :path,
          :iambic_writer_method_to_be_provided, :paths,

          :properties, :as_normal_value, :on_event_selectively


        def initialize & p
          @as_normal_value = DEFAULT_AS_NORMAL_VALUE_PROC__
          @on_event_selectively = DEFAULT_ON_EVENT_SELECTIVELY__
          # ~ ivars related to fields, alphabeticized by field's name
          @unescaped_filename_a = []
          @freeform_query_infix = nil
          @unescaped_ignore_dir_a = []
          @unescaped_path_a = []
          instance_exec( & p )
          if @unescaped_path_a.length.zero?
            @is_curry = true
          else
            @is_curry = false
            resolve_any_valid_command_string
          end
          freeze
        end

        DEFAULT_AS_NORMAL_VALUE_PROC__ = -> cmd do
          cmd.to_scan.to_a  # #todo - not yet implemented, part of the grand unification
        end

        DEFAULT_ON_EVENT_SELECTIVELY__ = -> i, * _, & ev_p do
          if :info != i
            raise ev.to_exception
          end
        end

        def mixed_result
          if @is_curry
            self
          elsif @any_valid_command_string
            @as_normal_value[ self ]
          else
            @last_error_result  # #todo
          end
        end

      private

        def freeze
          @unescaped_filename_a.freeze
          @unescaped_ignore_dir_a.freeze
          @unescaped_path_a.freeze
          super
        end

        def initialize_copy _otr_
          # do not freeze here, this dup is for internal copies whose
          # existing ivars are read-only but who must themselves reamain
          # mutable, see #note-130
        end

      protected

        def init_copy
          @unescaped_filename_a = @unescaped_filename_a.dup
          # assume '@freeform_query_infix' if set is frozen
          @unescaped_ignore_dir_a = @unescaped_ignore_dir_a.freeze
          @unescaped_path_a = @unescaped_path_a.dup
          nil
        end

      public

        def string
          @any_valid_command_string
        end

        def to_scan
          @any_valid_command_string and begin
            Find__::Build_scan__[ @on_event_selectively, @any_valid_command_string ]
          end
        end

      private

        def filename=
          @unescaped_filename_a.clear.push iambic_property
        end

        def filenames=
          # an "or" list
          @unescaped_filename_a.replace iambic_property
        end

        def freeform_query_infix=
          s = iambic_property
          if s
            if FREEFORM_QUERY_VALIDATION_HACK_RX__ =~ s
              s.frozen? or s.freeze  # or change how you dup, or require
              @freeform_query_infix = s
            else
              raise ::ArgumentError, "looks strange: #{ s.inspect }"  # just sanity
            end
          else
            @freeform_query_infix = s
          end ; nil
        end

        FREEFORM_QUERY_VALIDATION_HACK_RX__ = -> do
          part = '-?[a-z0-9]+'
          %r(\A#{ part }(?:[ ]#{ part })*\z)
        end.call

        def ignore_dirs=
          @unescaped_ignore_dir_a.replace iambic_property
        end

        def path=
          @unescaped_path_a.clear.push iambic_property
        end

        def paths=
          @unescaped_path_a.clear.replace iambic_property
        end

        # ~ done with iambic writers

        def resolve_any_valid_command_string  # amazing hax #note-130
          otr = dup
          otr.singleton_class.send :prepend, Command_String_Building_Methods__
          s = otr.execute
          if s
            @any_valid_command_string = s.freeze
            @on_event_selectively.call :info, :command_string do
              Command_String_Event__[ s ]
            end
          else
            @any_valid_command_string = UNABLE_
          end
          nil
        end

        Command_String_Event__ = Headless_::Lib_::Event_lib[].prototype_with(

            :command_string, :command_string, nil, :ok, nil ) do |y, o|

          y << "generated `find` command: #{ o.command_string }"
        end

        module Command_String_Building_Methods__

          # assume nonzero paths

          def execute
            @y = [ 'find' ]
            append_nonzero_paths
            if @unescaped_ignore_dir_a.length.nonzero?
              append_ignore_dir_phrase
            end
            if @freeform_query_infix
              @y.push @freeform_query_infix
            end
            if @unescaped_filename_a.length.nonzero?
              append_name_phrase
            end
            @y * SPACE_
          end

        private

          def append_nonzero_paths
            @unescaped_path_a.each do |s|
              @y.push Headless_::Lib_::Shellwords[].escape s
            end ; nil
          end

          def append_ignore_dir_phrase
            @y.push '-not \( -type d \( -mindepth 1 -a'
            @y.push ignore_dir_orlist
            @y.push '\) -prune \)'
          end

          def ignore_dir_orlist
            orlist_via_unescaped_value_array @unescaped_ignore_dir_a
          end

          def append_name_phrase
            @y.push '\('
            @y.push name_orlist
            @y.push '\)'
          end

          def name_orlist
            orlist_via_unescaped_value_array @unescaped_filename_a
          end

          def orlist_via_unescaped_value_array a
            a.map do |s|
              "-name #{ Dangerous_conditional_shellescape_path__[ s ] }"
            end.join ' -o '
          end

          Dangerous_conditional_shellescape_path__ = -> s do
            Headless_::Lib_::Shellwords[].escape s  # placeholder for hax
          end
        end
      end
    end
  end
end
# :+#posterity :+#tombstone `collapse` was an early ancestor of the n11n pattern
# :+#posterity :+#tombstone the find node that used to be in [st] deleted
