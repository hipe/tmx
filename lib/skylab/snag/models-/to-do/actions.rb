module Skylab::Snag

    if false  # class Actions::Melt

    option_parser do |o|
      dry_run_option o
      name_option o
      pattern_option o
      verbose_option o
    end

    desc do |y|
      a = Snag_::API::Actions::ToDo::Melt.attributes[ :paths ][ :default ]
      expression_agent.calculate do
        a = a.map( & method( :ick ) )
        y << 'arguments:'
        y << "  #{ par :path }#{
          }#{ SPACE_ * 20 }the path(s) to search (default: #{ a * ', '})"
      end
    end

    inflection.inflect.noun :plural

    def melt *path
      if path.length.zero?  # triggering dflts to list params is not automatic
        path.concat Snag_::API::Actions::ToDo::Melt.attributes[ :paths ][ :default ]
      end
      call_API [ :to_do, :melt ],
        {           dry_run: false,
                      paths: path,
                 be_verbose: false,
                working_dir: working_directory_path
        }.merge!( @param_h ),
       -> o do
        o.on_error_event handle_error_event
        o.on_error_string handle_error_string
        o.on_info_event handle_info_event
        o.on_info_line handle_info_line
        o.on_info_string handle_inside_info_string
      end
    end
    end
end
