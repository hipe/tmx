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
                 be_verbose: false,
                    dry_run: false,
                   node_ref: node_ref
        }.merge( @param_h ) do |a|
        a.on_info handle_info
        a.on_error handle_error
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

    def add node_ref, tag_name
      call_API [ :node, :tags, :add ], {
                 be_verbose: false,
                  do_append: true,
                    dry_run: false,
                   node_ref: node_ref,
                   tag_name: tag_name
      }.merge( @param_h ) do |a|
        a.on_error handle_error
        a.on_info handle_info
      end
    end

    desc 'list the tags for a given node.'

    def ls node_ref
      call_API(
        [ :node, :tags, :ls ],
        { node_ref: node_ref },
        -> o do
          o.on_error handle_error
          o.on_tags do |tags|
            payload tags.render_under( self )  # just for fun i tell you
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
      par_h = { dry_run: false, node_ref: node_ref,
        tag_name: tag_name, be_verbose: false }
      par_h.merge! @param_h
      call_API [ :node, :tags, :rm ], par_h do |o|
        o.on_error handle_error
        o.on_info handle_info
        o.on_payload handle_payload
      end
    end
  end
end
