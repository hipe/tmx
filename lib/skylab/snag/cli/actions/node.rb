module Skylab::Snag

  class CLI::Actions::Node < CLI::Action::Box

    box.desc 'actions that act on a given node'

    desc 'close a node (remove tag #open and add tag #done)'

    option_parser do |o|
      dry_run_option o
      verbose_option o
    end

    def close node_ref
      call_API [ :node, :close ], {
                    dry_run: false,
                   node_ref: node_ref,
                 be_verbose: false,
                working_dir: working_directory_path
        }.merge( @param_h ) do |a|
        a.on_error_event handle_error_event
        a.on_error_string handle_error_string
        a.on_info_event handle_info_event
      end
    end
  end

  class CLI::Actions::Node::Actions::Tags < CLI::Action::Box

    box.desc 'actions for tags on a given node'

    desc 'add a tag to a node.'

    option_parser do |o|
      dry_run_option o

      o.on '-p', '--prepend', "prepend, as opposed to append, the tag #{
        }to the message" do @param_h[:do_append] = false end

      verbose_option o
    end

    inflection.inflect.noun :singular

    def add node_ref, tag_name
      call_API [ :node, :tags, :add ], {
                 be_verbose: false,
                  do_append: true,
                    dry_run: false,
                   node_ref: node_ref,
                   tag_name: tag_name,
                working_dir: working_directory_path
      }.merge( @param_h ) do |o|
        o.on_error_event handle_error_event
        o.on_info_event handle_info_event
      end
    end

    desc 'list the tags for a given node.'

    inflection.inflect.noun :plural

    def ls node_ref
      call_API( [ :node, :tags, :ls ], {
                    node_ref: node_ref,
                 working_dir: working_directory_path
        }, -> o do
          o.on_error_event handle_error_event
          o.on_tags do |tags|
            tags.render_all_lines_into_under y=[], expression_agent
            send_payload_line y * SPACE_ ; nil
          end

        end )
    end

    desc 'remove a tag from a node.'

    option_parser do |o|
      dry_run_option o
      verbose_option o
    end

    inflection.inflect.noun :singular

    def rm node_ref, tag_name
      call_API [ :node, :tags, :rm ], {
                    dry_run: false,
                   node_ref: node_ref,
                   tag_name: tag_name,
                 be_verbose: false,
                working_dir: working_directory_path
      }.merge!( @param_h ), -> o do
        o.on_error_event handle_error_event
        o.on_error_string handle_error_string
        o.on_info_event handle_info_event
        o.on_payload handle_payload_line
      end
    end
  end
end
