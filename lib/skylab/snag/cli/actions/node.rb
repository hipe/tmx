module Skylab::Snag

  class CLI::Actions::Node < CLI::Action::Box

    cli_box_dsl_original_desc 'actions that act on a given node'

    desc 'close a node (remove tag #open and add tag #done)'

    option_parser do |o|
      dry_run_option o
      verbose_option o
    end

    def close node_ref
      api_invoke [ :node, :close ], {
          dry_run: false, node_ref: node_ref, verbose: false,
        }.merge( param_h )
    end
  end

  class CLI::Actions::Node::Actions::Tags < CLI::Action::Box

    cli_box_dsl_original_desc 'actions for tags on a given node'

    desc 'add a tag to a node.'

    option_parser do |o|
      dry_run_option o

      o.on '-p', '--prepend', "prepend, as opposed to append, the tag #{
        }to the message" do param_h[:do_append] = false end

      verbose_option o
    end

    def add node_ref, tag_name
      api_invoke [:node, :tags, :add],
        { dry_run: false,
          node_ref: node_ref,
          do_append: true,
          tag_name: tag_name,
          verbose: false }.merge( param_h )
    end

    desc 'list the tags for a given node.'

    def ls node_ref
      api_invoke( [:node, :tags, :ls],
        { node_ref: node_ref },
        -> api_action do
          wire_action_for_error api_action
          api_action.on_payload do |e|         # just for fun we make the
            payload e.payload.render_for( self ) # payload crunchy
            nil
          end
        end )
    end

    desc 'remove a tag from a node.'

    option_parser do |o|
      dry_run_option o
      verbose_option o
    end

    def rm node_ref, tag_name
      api_invoke [:node, :tags, :rm],
        { dry_run: false, node_ref: node_ref, tag_name: tag_name,
          verbose: false }.merge( param_h )
    end
  end
end
