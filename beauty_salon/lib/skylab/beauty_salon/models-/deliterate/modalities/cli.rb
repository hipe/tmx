module Skylab::BeautySalon

  class Models_::Deliterate

    module Modalities::CLI

      Actions = ::Module.new
      class Actions::Deliterate < Brazen_::CLI::Action_Adapter

        # (what happens here is mentored by [gi])

        MUTATE_THESE_PROPERTIES = [
          :code_line_downstream,
          :comment_line_downstream,
          :line_upstream,
        ]

        def mutate__code_line_downstream__properties

          substitute_value_for_argument :code_line_downstream do
            @resources.sout
          end
        end

        def mutate__comment_line_downstream__properties

          # by design, the back service adds no newlines to these flushed
          # paragraphs. if we don't do this ourselves it's contrary to the
          # modality convention and looks/behaves kind of nastily.

          _y = ::Enumerator::Yielder.new do | line |
            @resources.serr.puts line
          end

          substitute_value_for_argument :comment_line_downstream do
            _y
          end
        end

        def mutate__line_upstream__properties

          mfp = mutable_front_properties
          mfp.remove :line_upstream

          _prp = build_property(
            :file,
            :required,
            :description, -> y do
              y << "a file with code in it"
            end,
          )

          mfp.add :file, _prp
          NIL_
        end

        def prepare_backstream_call x_a

          _qkn = remove_backstream_argument :file

          kn = Home_.lib_.system_lib::Filesystem::Normalizations::Upstream_IO.via(

            :qualified_knownness_of_path, _qkn,
            :filesystem, @resources.bridge_for( :filesystem ),
            & handle_event_selectively
          )

          if kn
            x_a.push :line_upstream, kn.value
            ACHIEVED_
          else
            kn
          end
        end
      end
    end
  end
end
