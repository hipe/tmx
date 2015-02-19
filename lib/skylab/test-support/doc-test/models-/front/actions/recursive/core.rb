module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive < Action_

        # ~ enum experiment ( abstraction candidate )

        edit_entity_class do

          entity_property_class_for_write  # abstraction candidate

          class self::Entity_Property
          private

            def enum=

              set_sym_a = iambic_property

              _ENUM_BOX_P = Callback_.memoize do
                bx = Callback_::Box.new
                set_sym_a.each do | sym |
                  bx.add sym, true
                end
                bx
              end

              add_to_write_proc_chain do | _PROP |
                -> do
                  x = iambic_property.intern
                  if _ENUM_BOX_P[][ x ]
                    receive_value_of_entity_property x, _PROP
                  else
                    receive_bad_enum_value x, _PROP.name_symbol, _ENUM_BOX_P[]
                  end
                end
              end

              @enum_members_p = -> do
                set_sym_a.dup
              end

              KEEP_PARSING_
            end

          public

            def enum_members
              @enum_members_p[]
            end
          end
        end

        def receive_bad_enum_value x, name_sym, enum_box  # #hook-near [br]
          maybe_send_event :error, :invalid_property_value do
            bld_bad_enum_value_event x, name_sym, enum_box
          end
        end

        define_method :bld_bad_enum_value_event,
          Lib_::Bzn_[]::Entity.build_bad_enum_value_event_method_proc

        # ~ end experiments

        edit_entity_class :promote_action,

            :after, :generate,

            :inflect,
              :verb, '(recursively) generate',
              :noun, 'document',

            :desc, -> y do
                y << 'generate multiple documents at once'
                y << 'using a manifest file'
            end,

            :description, -> y do
              a = DocTest_.get_output_adapter_slug_array
              y << "available adapter#{ s a }: #{ a * ' | ' }"
            end,
            :default, :quickie,
            :property, :output_adapter,

            :flag,
            :description, -> y do
              y << "necessary to overwrite existing files"
            end,
            :property, :force,

            :enum, [ :list, :preview ],
            :description, -> y do
              _prop = Recursive_.property_via_symbol :sub_action
              y << "{ #{ _prop.enum_members * ' | ' } }"
            end,
            :property, :sub_action,

            :flag,
            :description, -> y do
              y << 'do not actually write files'
            end,
            :property, :dry_run,

            :hidden, :property, :downstream,

            :required,
              :description, -> y do

                y << "a file or directory of code as input"

              end,
              :property, :path


        def initialize boundish  # and oes_p
          super
        end

        def normalize
          super and _normalize
        end

        def _normalize

          via_properties_init_ivars

          o = TestSupport_.lib_.system.defaults
          @doc_test_dir = o.doc_test_dir
          @doc_test_files_file = o.doc_test_files_file

          pn = ::Pathname.new @path
          if pn.relative?
            @path = pn.expand_path.to_path
          end

          @sub_action ||= :none

          if :preview == @sub_action && ! @downstream
            maybe_send_event :error, :missing_required_properties do
              TestSupport_.lib_.entity.properties_stack.
                build_missing_required_properties_event(
                  [ self.class.property_via_symbol( :downstream ) ] )
            end
            UNABLE_
          else
            ACHIEVED_
          end
        end

        def produce_result
          struct = Recursive_::Actors__::Produce_manifest_entry_stream[
            @path,
            @doc_test_dir,
            @doc_test_files_file,
            self.class.property_via_symbol( :path ),
            handle_event_selectively ]

          struct and begin
            @lines, @top_path = struct.to_a
            via_lines_and_top_path
          end
        end

        def via_lines_and_top_path
          @st = via_lines_and_top_path_build_matching_entry_stream
          case @sub_action
          when :list
            @st
          when :preview
            result_via_proto proto_for_preview
          when :none
            result_via_proto proto_for_generate
          end
        end

      private

        def proto_for_preview
          common_prototype_with :line_downstream, @downstream
        end

        def proto_for_generate
          common_prototype_with
        end

        def common_prototype_with * x_a

          Actions::Generate.new(

            @kernel, & @on_event_selectively ).curry_action_with__(

              * ( :dry_run if @dry_run ),
              * ( :force if @force ),
              :output_adapter, @output_adapter,
              * x_a )
        end

        def result_via_proto proto

          @st.map_by do | entry |

            # because this is a map and not a map reduce, it will break
            # the processing chain as soon as one fails. but this could
            # be changed.

            x_a = [
              :upstream_path, entry.get_absolute_path ]

            tagging_a = entry.tagging_a
            if tagging_a
              tagging_a.each do | tagging |
                x = tagging.value_x
                if x.nil?
                  x_a.push tagging.normal_name_symbol
                else
                  x_a.push tagging.normal_name_symbol, x
                end
              end
            end

            proto.new_via_iambic x_a

          end
        end

        def via_lines_and_top_path_build_matching_entry_stream

          # this is a hand-written reduce-map-reduce: skipping irrelevant
          # lines in the manifest, with each relevant line (as an "entry"
          # instance) produce only those entries whose paths are equal to
          # or under the argument path. if we stop early, close the file.

          st = via_lines_and_top_path_bld_entry_stream

          target_path_length = @path.length

          match = -> path do
            len = path.length
            case len <=> target_path_length

            when -1  # current path is shorter than target path
              false

            when  0  # current path when same length as target path
              @path == path

            when  1  # current path is longer that target path
              part = path[ 0, target_path_length ]
              if @path == part
                if SLASH_BYTE_ == path.getbyte( target_path_length )
                  true  # current path looks like a sub-path
                else
                  false  # but one day we might let these through
                end
              else
                false
              end
            end
          end

          middle_segment_p = nil
          p = -> do
            begin
              entry = st.gets
              entry or break
              _yes = match[ entry.get_absolute_path ]
              _yes or redo
              p = middle_segment_p
              break
            end while nil
            entry
          end

          middle_segment_p = -> do
            begin
              entry = st.gets
              entry or break
              _yes = match[ entry.get_absolute_path ]
              _yes and break

              # assuming the manifest is in lexical order, if you have at
              # least once before seen a matching entry, and this current
              # entry does not match then we need not continue the search

              @lines.close
              p = EMPTY_P_
              entry = nil
              break

            end while nil
            entry
          end

          Callback_.stream do
            p[]
          end
        end

        def via_lines_and_top_path_bld_entry_stream

          proto = Recursive_::Models__::Manifest_Entry.new(
            @top_path, & handle_event_selectively )

          Callback_.stream do
            begin
              line = @lines.gets
              line or break
              entry = proto.any_new_valid_via_mutable_line line
              entry or redo
              break
            end while nil
            entry
          end
        end

        Recursive_ = self

        SLASH_BYTE_ = '/'.getbyte 0
      end
    end
  end
end
