module Skylab::FileMetrics

  class Models_::Report

    br = FM_.lib_.brazen

    emod = br::Model::Entity

    class Report_Action_ < br::Action
    private

      def build_find_files_command_via_paths_ path_a

        h = @argument_box.h_

        FM_.lib_.system.filesystem.find(

          :paths, path_a,
          :ignore_dirs, h.fetch( :exclude_dir ),
          :filenames, h[ :include_name ],
          :freeform_query_infix_words, %w'-not -type d',
          :as_normal_value, IDENTITY_

        ) do | * i_a, & ev_p |

          if :info != i_a.first
            @on_event_selectively.call( * i_a, & ev_p )
          end
        end
      end

      def filesystem_conduit_
        FM_.lib_.system.filesystem
      end

      def system_conduit_
        FM_.lib_.open_3
      end
    end

    Entity_ = -> action_cls, * x_a do

      raise ::ArgumentError if block_given?

      br::Entity::Edit_client_class_via_polymorphic_stream_over_extmod[

        action_cls,
        Callback_::Polymorphic_Stream.via_array( x_a ),
        emod ]
    end

    COMMON_PROPERTIES_ = br::Model.common_properties_class.new emod do | sess |

      sess.edit_common_properties_module(

        :description, -> y do

          y << "directories whose basename matches this pattern will #{
            }be skipped."

          y << "adding more patterns narrows the search."

          y << "the default is to skip directories whose name begins #{
            }with a dot ('.*')."

          y << "(ETC explain the thing with the '[]')"

        end,
        :argument_arity, :zero_or_more,
        :ad_hoc_normalizer, -> qkn, & oes_p do
          if '[]' == qkn.value_x.last
            qkn.value_x.clear
          end
          qkn
        end,
        :default, [ '.*' ],
        :property, :exclude_dir,

        :description, -> y do

          y << "e.g. --name='*.rb'. When present, this limits the files"
          y << 'reported on to those that match the pattern(s).'
          y << 'adding more patterns broadens the search (OR not AND).'
          y << 'this option is only relevant on directories.'
        end,
        :argument_arity, :zero_or_more,
        :property, :include_name,

        :description, -> y do
          y <<  "whether or not to actually run the report (dry-run-esque)"
        end,
        :default, true,
        :flag,
        :property, :show_report,
      )
    end

    module Actions

      class Ping < Report_Action_

        @is_promoted = true

        # set :node, :ping, :invisible  # :+[#br-095]

        def produce_result

          @on_event_selectively.call :info, :expression, :ping do | y |
            y << "hello from file metrics."
          end
          :hello_from_file_metrics
        end
      end

      Autoloader_[ self, :boxxy ]
    end

    Report_ = self
    Autoloader_[ Sessions_ = ::Module.new ]
  end
end
