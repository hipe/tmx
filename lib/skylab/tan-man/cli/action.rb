module Skylab::TanMan
  module CLI::ActionInstanceMethods
    include API::RuntimeExtensions
    def infostream
      if parent
        parent.infostream
      else
        fail("where is infostream for #{self.class}")
      end
    end
    def runtime
      parent # their api to ours
    end
  end

  class CLI
    include CLI::ActionInstanceMethods
  end

  class CLI::Action
    extend Bleeding::ActionModuleMethods
    extend Bleeding::DelegatesTo
    extend ::Skylab::PubSub::Emitter
    include CLI::ActionInstanceMethods

    emits :out, Core::Event::GRAPH
    event_class Core::Event

    alias_method :action_class, :class

    delegates_to :action_class, :action_name

    def self.action_name # @todo couches 100
      aliases.first # pathify(to_s.split('::').last)
    end
    def self.invocation_syntax #@todo couches 100
      "#{aliases.first} #{syntax}"
    end

    def api
      @api ||= begin
        API::Binding.new(self)
      end
    end

    def format_error event
      event.tap do |e|
        if runtime.runtime
          subj, verb, obj = [runtime.runtime.program_name, aliases.first, runtime.aliases.first]
        else
          subj, verb = [runtime.program_name, aliases.first]
        end
        e.message = "#{subj} failed to #{verb}#{" #{obj}" if obj}: #{e.message}"
      end
    end

    def full_action_name_parts
      a = [aliases.first]
      root_id = root_runtime.object_id
      current = self
      loop do
        root_id == current.runtime.object_id and break
        a.push(( current = current.runtime).aliases.first)
      end
      a.reverse
    end

    def infostream ; runtime.infostream end

    def initialize
      @api = nil
      on_no_config_dir do |e|
        emit(:error, "couldn't find #{e.touch!.dirname} in this or any parent directory: #{e.from.pretty}")
        emit(:info, "(try #{pre( "#{root_runtime.program_name} " <<
          CLI::Actions::Init.invocation_syntax )} to create it)")
      end
      on_info  { |e| e.message = "#{runtime.program_name} #{action_name}: #{e.message}" }
      on_error { |e| add_invalid_reason( format_error e ) }
      on_all   { |e| runtime.emit(e) unless e.touched? }
    end

    alias_method :on_no_action_name, :full_action_name_parts

    delegates_to :runtime, :text_styler
  end

  module CLI::NamespaceModuleMethods
    include Bleeding::NamespaceModuleMethods
    def build runtime
      CLI::NamespaceRuntime.new(self).build(runtime)
    end
  end

  class CLI::NamespaceRuntime < Bleeding::NamespaceInferred
    include API::RuntimeExtensions
    include CLI::ActionInstanceMethods
  end
end
