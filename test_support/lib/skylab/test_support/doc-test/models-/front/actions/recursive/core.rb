module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive < Action_

        # ~ :+[#br-082] abstraction candidate - enum

        # ~~ ( not used yet (per se):
        _base_cls = if const_defined? :Property
          self::Property
        else
          Brazen_::Modelesque::Entity::Property
        end

        const_set :Property, ::Class.new( _base_cls )
        # ~~ )

        def sub_action  # while #open [#br-088]

          @argument_box[ :sub_action ]  # often nil
        end

        def ___ME_receive_bad_enum_value x, prp_name, x_a

          maybe_send_event :error, :invalid_property_value do

            Home_.lib_.fields::MetaMetaFields::Enum::
              Build_extra_value_event[ x, enum_box.get_names, prp_name ]
          end
        end

        # ~ end experiments

        edit_entity_class :promote_action,

            :after, :generate,

            :inflect,
              :verb, '(recursively) generate',
              :noun, 'document',

            :branch_description, -> y do
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

              _prp = Recursive_.properties.fetch :sub_action
              y << "{ #{ _prp.enum_box.get_names * ' | ' } }"

            end,
            :property, :sub_action,

            :flag,
            :description, -> y do
              y << 'do not actually write files'
            end,
            :property, :dry_run,

            :property, :downstream,

            :required,
            :description, -> y do
              y << "a file or directory of code as input"
            end,
            :property, :path


        def initialize boundish  # and oes_p
          super
        end

        def normalize
          super and __my_normalize
        end

        def __my_normalize

          via_properties_init_ivars

          @doc_test_files_file = Manifest_filename_[]

          pn = ::Pathname.new @path
          if pn.relative?
            @path = pn.expand_path.to_path
          end

          @sub_action ||= :none

          if :preview == @sub_action && ! @downstream
            maybe_send_event :error, :missing_required_properties do
              Home_.lib_.brazen::Property.
                build_missing_required_properties_event(
                  [ self.class.properties.fetch( :downstream ) ] )
            end
            UNABLE_
          else
            ACHIEVED_
          end
        end

        def produce_result

          struct = Recursive_::Actors__::Produce_manifest_entry_stream[
            @path,
            @doc_test_files_file,
            self.class.properties.fetch( :path ),
            & handle_event_selectively ]

          struct and begin

            @lines = struct.open_file_IO
            @manifest_patch = struct.manifest_path
            @top_path = struct.surrounding_path

            __via_lines_and_manifest_path
          end
        end

        def __via_lines_and_manifest_path

          @st = __via_lines_and_manifest_path_build_matching_entry_stream
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

        def __via_lines_and_manifest_path_build_matching_entry_stream

          # this is a hand-written reduce-map-reduce: skipping irrelevant
          # lines in the manifest, with each relevant line (as an "entry"
          # instance) produce only those entries whose paths are equal to
          # or under the argument path. if we stop early, close the file.

          st = __via_lines_and_manifest_path_build_entry_stream

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

        def __via_lines_and_manifest_path_build_entry_stream

          proto = Recursive_::Models__::Manifest_Entry.new(

            @top_path,

            & handle_event_selectively )

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
