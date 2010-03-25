module Hipe
  module Assess
    module Commands

      listing_index 200

      SchemaSubs = %w(analyze protomodel datamapper destroy check)

      o "#{app} schema ( #{SchemaSubs.join('|')} ) [OPTS] [ARGS]"
      x 'Analyze patterns on json data, mebbe guess at a schema. (-h)'
      x 'Maybe generate a datamapper model. Maybe build the model.'
      x "If you are lucky, there is more help under the subcommans with -h"
      def schema opts, *args
        subcommand_dispatch SchemaSubs, opts, args
      end

    protected

      o "#{app} schema analyze [JSON_FILE]"
      x ('Show statistics and type guesses for each field in the data. '<<
        ' (step 1)')
      x "This will inform the guesses it makes when guessing a schema."
      def schema_analyze opts, file=nil
        return help if opts[:h]
        sin = input_from_stdin_or_filename(file) or return
        require 'assess/proto/json-schema-guess.rb'
        JsonSchemaGuess.process_analyze_request sin, ui
      end

      o "#{app} schema protomodel [-s] ENTITY_NAME [JSON_FILE]"
      x ("See the non-orm specific schema guess based on the input data."<<
        '(step 2)')
      x "It guesses table names from column names, but needs to know a name"
      x "  to use for the main table that holds this type of entity."
      x '(use "-s" option to force it to allow a name that ends with an "s")'
      def schema_protomodel opts, entity_name=nil, file=nil
        return help if opts[:h]
        return help unless entity_name_valid?(
          'entity name', opts, entity_name
        )
        sin = input_from_stdin_or_filename(file) or return
        require 'assess/proto/json-schema-guess.rb'
        JsonSchemaGuess.process_protomodel_request sin, ui, entity_name
      end

      InvalidEntCharsRe = /[^_a-z0-9]/
      def entity_name_valid? soft_name, opts, entity_name
        no = entity_name.to_s.scan(InvalidEntCharsRe).uniq.join('')
        if ! no.empty?
          ui.puts "Invalid #{soft_name} #{entity_name.inspect}."
          ui.puts("#{titleize(soft_name)} should not contain #{no.inspect}.")
          describe_entity_name_policy
          false
        elsif(/s\Z/ =~ entity_name && !opts[:s])
          ui.puts "Invalid #{soft_name}.  Use singular not pluaral."
          ui.puts "(Or to force it to take this name, use '-s')"
          describe_entity_name_policy
          false
        else
          true
        end
      end

      def describe_entity_name_policy
        ui.puts "To keep our lives simple we want singular names"
        ui.puts "with underscores in them."
      end

      o "#{app} schema datamapper ENTITY_NAME APP_NAME [JSON_FILE]"
      x ("Output to stdout the orm-specfic ruby code for the datamodel." <<
        " (step 3)")
      x "(in this case datamappper.)"
      def schema_datamapper opts, entity_name=nil, app_name=nil, file=nil
        return help if opts[:h]
        return help unless entity_name_valid?('entity name',opts,entity_name)
        return help unless entity_name_valid?('app name',opts,app_name)
        sin = input_from_stdin_or_filename(file) or return
        require 'assess/proto/json-schema-guess.rb'
        require 'assess/code-adapter/data-mapper'
        metrics = JsonSchemaGuess.entity_metrics sin
        proto = JsonSchemaGuess.protomodel_from_metrics metrics, entity_name
        sexp = DataMapper.schema_builder.model_sexp_from_protomodel(
          proto, app_name
        )
        ui.puts sexp.to_ruby
      end

      o "#{app} schema destroy"
      x ("Clobber your database and rebuild your schema from the model."<<
        ' (step 4)')
      x "This requires that your datamodel exist (in files), of course."
      def schema_destroy opts, *a
        require 'assess/code-adapter/framework-common'
        return help if opts[:h]
        FrameworkCommon.dispatch_migrate ui, opts
      end

      # o "#{app} schema check"
      x ("Check if db schema is a superset of the datamodel schema "<<
        '(not implemented)')
      def schema_check *a
        ui.puts("Sorry, check is not yet implemented!")
      end
    end
  end
end
