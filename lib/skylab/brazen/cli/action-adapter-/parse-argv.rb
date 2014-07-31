module Skylab::Brazen

  module CLI

    class Action_Adapter_

      class Parse_ARGV

        def initialize client, action, argv
          @client = client ; @action = action ; @argv = argv
          @out = @client.stderr
          @result = nil
        end

        def execute
          partition_parameters
          rslv_option_parser
          result = parse_options
          result ||= parse_arguments
          result || three_for_success
        end

      private

        def partition_parameters
          scn = @action.get_property_scanner
          arg_a = opt_a = nil
          while (( prop = scn.gets ))
            if prop.is_required
              ( arg_a ||= [] ).push prop
            else
              ( opt_a ||= [] ).push prop
            end
          end
          # experimental aesthetics - fill the trailing optional arg "slot"
          if opt_a && ! arg_a && opt_a.last.has_default
            ( arg_a ||= [] ).push opt_a.pop
            opt_a.length.zero? and opt_a = nil
          end
          @opt_a = opt_a ; @arg_a = arg_a ; nil
        end

        def rslv_option_parser
          @op = CLI::Lib_::Option_parser[].new
          @opt_a and populate_option_parser_with_generated_options
          populate_option_parser_with_universal_options
        end

        def populate_option_parser_with_generated_options
          h = build_unique_letter_hash
          @opt_a.each do |prop|
            args = []
            letter = h[ prop.name_i ]
            letter and args.push "-#{ letter }"
            base = "--#{ prop.name.as_slug }"
            if prop.takes_argument
              args.push "#{ base } #{ argument_label_for prop }"
              p = -> x do
              end
            else
              args.push base
              p = -> do
              end
            end
            if prop.has_description
              args.concat prop.get_description_lines
            end
            @op.on( * args, & p )
          end ; nil
        end

        def build_unique_letter_hash
          num_times_seen_h = ::Hash.new { |h, k| h[ k ] = 0 } ; h = { }
          @opt_a.each do |prop|
            name_s = prop.name.as_variegated_string
            d = name_s.getbyte 0
            case num_times_seen_h[ d ] += 1
            when 1
              h[ prop.name_i ] = name_s[ 0, 1 ]
            when 2
              h.delete prop.name_i
            end
          end
          h
        end

        def argument_label_for prop  # :+#hack
          prop.name.as_variegated_string.split( UNDERSCORE_ ).last.upcase
        end

        def populate_option_parser_with_universal_options
          @op.on '-h', '--help', 'this screen' do
            build_help.output_help_screen
            @result = SUCCESS_
          end
          nil
        end

        def parse_options
          @result = PROCEDE_
          @op.parse! @argv
          @result
        rescue ::OptionParser::ParseError => e
          CLI::State_Processors_::When_Parse_Error.
            new( e, build_help, @out ).execute
        end

        def parse_arguments

        end

        def build_help
          Action_Adapter_::Help_Renderer.
            new @action, @op, @arg_a, @client
        end

        def three_for_success

        end
      end
    end
  end
end
