module Hipe
  module Assess
    module Commands
      SchemaSubs = %w(analyze protomodel dm destroy)

      o "#{app} schema ( #{SchemaSubs.join('|')} ) [OPTS] [ARGS]"
      x 'Analyze patterns on json data, mebbe guess at a schema.'
      x 'Maybe generate a datamapper model. Maybe build the model.'
      x "If you are lucky, there is more help under the subcommans with -h"
      def schema opts, *args
        return help if opts[:h] && ! args.any?
        sub_command_dispatch SchemaSubs, opts, args
      end

    protected

      o "#{app} schema analyze [JSON_FILE]"
      x 'Show statistics and type guesses for each field in the data.'
      x "This will inform the guesses it makes when guessing a schema."
      def schema_analyze opts, file=nil
        return help if opts[:h]
        sin = input_from_stdin_or_filename(file) or return
        require 'assess/proto/json-schema-guess.rb'
        JsonSchemaGuess.analyze sin, ui
      end

      o "#{app} schema protomodel [-s] ENTITY_NAME [JSON_FILE]"
      x "See the non-orm specific schema guess."
      x '(use "-s" option to force it to allow a name that ends with an "s")'
      def schema_protomodel opts, entity_name=nil, file=nil
        return help if opts[:h]
        return help unless entity_name_valid?(
          'entity name', opts, entity_name
        )
        sin = input_from_stdin_or_filename(file) or return
        require 'assess/proto/json-schema-guess.rb'
        JsonSchemaGuess.protomodel sin, ui, entity_name
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

      o "#{app} schema dm ENTITY_NAME APP_NAME [JSON_FILE]"
      x "Output to stdout the orm-specfic (in this case"
      x "DataMapper) ruby code for the model."
      def schema_dm opts, entity_name=nil, app_name=nil, file=nil
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
        sexp = ridiculous_hook_hack(sexp)
        ui.puts sexp.to_ruby
      end

      def ridiculous_hook_hack(module_sexp)
        ruby = ("hooks = File.dirname(__FILE__)+'/model-hooks.rb';"<<
          "require(hooks) if File.exist?(hooks)"
        )
        block = CodeBuilder::BlockeySexp[CodeBuilder.parse(ruby)]
        # ruby parser turns __FILE__ into "(string)"
        block[1][2][1][3][1] = s(:const, :__FILE__)
        block.push module_sexp
        block
      end

      o "#{app} schema destroy"
      x "if your model is written to a file this will"
      x " clobber your database etc and rebuild your schema"
      def schema_destroy opts, *a
        require 'assess/code-adapter/framework-common'
        return help if opts[:h]
        FrameworkCommon.dispatch_migrate ui, opts
      end
    end
  end
end
