module Skylab::BeautySalon

  module Models_::Text

    module Modalities::CLI

      Actions = ::Module.new
      class Actions::Wrap < Brazen_::CLI::Action_Adapter

        # (what happens here is also mentored by [gi])

        MUTATE_THESE_PROPERTIES = [
          :informational_downstream,
          :output_bytestream,
          :upstream,
        ]

        def mutate__informational_downstream__properties

          substitute_value_for_argument :informational_downstream do
            @resources.serr
          end
        end

        def mutate__output_bytestream__properties

          substitute_value_for_argument :output_bytestream do
            @resources.sout
          end
        end

        def mutate__upstream__properties

          mutable_front_properties.replace_by :upstream do | prp |

            prp.dup.describe_by do | y |
              y << "if `-`, non-interactive STDIN is expected"
            end
          end

          mutable_back_properties.replace_by :upstream do | prp |

            prp.dup.append_ad_hoc_normalizer do | arg, & oes_p |

              Home_.lib_.system_lib::Filesystem::Normalizations::Upstream_IO.via(

                :qualified_knownness_of_path, arg,
                :stdin, @resources.sin,
                :recognize_common_string_patterns,
                :dash_means, :stdin,
                :filesystem, Home_.lib_.system.filesystem,
                & oes_p )
            end
          end
        end
      end

      # ==
      # ==
    end
  end
end
