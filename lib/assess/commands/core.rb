#
# using chris wanstrath's pattern from rip
#
module Hipe
  module Assess
    module Commands
      x 'Prints the current version and exits.'
      def version(options = {}, *args)
        ui.puts "#{app} #{Assess::Version}"
      end

      x 'See if u can connect to db.'
      def db opts={}, *args
        response = controller.db_check
        if :ok == response[:status]
          ui.puts "db ok: #{response[:message]}"
        else
          ui.puts "failed to connect: #{response[:message]}"
        end
      end

      x 'Init current directory for ramaze web app.'
      def ramaze opts={}, *args

      end

      x 'List domains.'
      def list opts={}, *args

      end

      o "#{app} schema (analyze | protomodel | dm) ENTITY_NAME [INFILE]"
      x 'Analyze patterns on json data, mebbe guess at a schema.'
      x 'Maybe generate a datamapper model.'

      def schema opts, sub_cmd=nil, entity_name=nil, file=nil
        return help(nil,'schema') if opts[:h]
        sin = input_from_stdin_or_filename(file) or return
        require 'assess/proto/json-schema-guess.rb'
        case sub_cmd
        when 'analyze'
          JsonSchemaGuess.analyze sin, ui
        when 'protomodel'
          JsonSchemaGuess.protomodel sin, ui, entity_name
        when 'dm'
          sexp = _generate_datamapper_model_sexp_from_json sin, entity_name
          ui.puts sexp.my_to_ruby
        else
          ui.puts("Need 'report' or 'model'.  \"#{sub_cmd}\" "<<
            "is not a valid sub-command.")
          return help nil, 'schema'
        end
      end

      def _generate_datamapper_model_sexp_from_json sin, entity_name
        require 'assess/proto/json-schema-guess.rb'
        require 'assess/code-adapter/data-mapper'
        metrics = JsonSchemaGuess.entity_metrics sin
        proto = JsonSchemaGuess.protomodel_from_metrics metrics, entity_name
        sexp = DataMapper.generate_model_module_sexp_from_protomodel proto
        sexp
      end

      x 'Import domain info from json.'
      o "#{app} import []"
      def import opts={}, *args
        if args.size > 1
          ui.puts "Too"
          return help()
        end
        debugger
        'x'

      end
    end
  end
end
