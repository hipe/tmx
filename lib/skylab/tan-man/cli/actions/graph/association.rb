module Skylab::TanMan
  module CLI::Actions::Graph::Association::Actions
    extend MetaHell::Boxxy
  end


  class CLI::Actions::Graph::Association::Actions::Add < CLI::Action

    desc "low-level adding of an association (label experiments!)"

    inflection.inflect.noun :singular

    option_parser do |o|
      dry_run_option o
      help_option o
      o.on '--label <lbl>',
        'experimentally include a label in the created association' do |v|
          param_h[:label] = v
      end
    end

    def process source_ref, target_ref
      api_invoke( {
           dry_run: false,
             label: false,
        source_ref: source_ref,
        target_ref: target_ref
      }.merge param_h )
    end
  end
end
