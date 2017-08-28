module Skylab::BeautySalon

  class Models_::Deliterate

    module Modalities::CLI

      Inject_and_deinject_associations = -> o do

        # ==

        #   - remove this association from the UI entirely
        #   - assign stdout to that ivar instead

        k = :code_line_downstream

        o.deinject_association k

        o.assign k do |rsx|
          rsx.stdout
        end


        # ==

        #   - remove this association from the UI entirely
        #   - assign something special to that ivar instead

        k = :comment_line_downstream

        o.deinject_association k

        o.assign k do |rsx|
          serr = rsx.stderr
          ::Enumerator::Yielder.new do |line|
            serr.puts line
          end
        end


        # ==

        -> do  # (scope)

          # this amounts to a dastardly demonstration of how association
          # injection/de-injection can change the interface quite a lot.
          # this is perhaps a smell that instead justifies a dedicated
          # custom action. this is referenced by :[#br-062.3].

          # in effect, we swap-in a "file" parameter for the "line upstream"
          # parameter; something that adds new behavior and requires work:

          #   - remove this association from the UI entirely.
          #   - add a whole other association, and some more abuse
          #   - at the end, make it look like we wrote to the original ivar


          frontend_sym = :file
          backend_sym = :line_upstream


          o.deinject_association backend_sym

          o.inject_association_via_definition(
            :required,
            :property,
            frontend_sym,
            :description, -> y do
              y << "a file with code in it"
            end,
          )

          o.inject_ad_hoc_normalization do |op, rsx|

            _trueish_x = op._simplified_read_ frontend_sym  # (was required, is guaranteed here)

            _asc = op.instance_variable_get( :@_associations_ ).fetch frontend_sym

            _qkn = Common_::QualifiedKnownness.via_value_and_association _trueish_x, _asc

            kn = Home_.lib_.system_lib::Filesystem::Normalizations::Upstream_IO.via(

              :qualified_knownness_of_path, _qkn,
              :filesystem, rsx.filesystem,
              & op.listener
            )

            if kn
              op._simplified_write_ kn.value, backend_sym
              ACHIEVED_
            end
          end
        end.call  # scope

        # ==
        # ==
      end  # `Inject_and_deinject_associations`
    end  # `CLI`
  end
end
# #history-A.1: full rewrite during sunset matryoshka
