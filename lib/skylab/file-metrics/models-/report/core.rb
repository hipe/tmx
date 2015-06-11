module Skylab::FileMetrics

  class Models_::Report

    br = FM_.lib_.brazen

    My_Entity__ = br::Model::Entity

    class Report_Action_ < br::Action

      def self.entity_enhancement_module
        My_Entity__
      end

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

      def stat_and_exception_ path  # :+[#sy-021]

        stat = begin
          e = nil
          filesystem_conduit_.stat path
        rescue ::Errno::ENOENT => e
          false
        end
        [ stat, e ]
      end

      def maybe_send_event_about_noent_ e

        @on_event_selectively.call :info, :enoent do

          Callback_::Event.wrap.exception.with(
            :exception, e,
            :path_hack,
            :terminal_channel_i, :enoent )
        end
        NIL_
      end

      def stdout_line_stream_via_args_ a
        o = Report_::Sessions_::Stdout_Stream.new( & @on_event_selectively )
        o.args = a
        o.system_conduit = system_conduit_
        o.execute
      end

      def filesystem_conduit_
        FM_.lib_.system.filesystem
      end

      def system_conduit_
        FM_.lib_.open_3
      end
    end

    COMMON_PROPERTIES_ = br::Model.common_properties_class.new My_Entity__ do | sess |

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
        :flag,
        :default, false,
        :property, :skip_report,
      )
    end

    Hack_lemma_via_symbol_ = -> sym do
      s = sym.id2name
      s.gsub! UNDERSCORE_, SPACE_
      s
    end

    UNDERSCORE_ = '_'

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
