module Skylab::TanMan

  class CLI::Action
  end


  module CLI::Action::InstanceMethods
    include Core::Action::InstanceMethods
  end


  class CLI::Action
    extend Bleeding::ActionModuleMethods # #018 porcelain will go
    extend Core::Action::ModuleMethods

    include CLI::Action::InstanceMethods

    def self.action_name # re-evaluated at [#033]
      aliases.first # pathify(to_s.split('::').last)
    end

    def self.invocation_syntax # revisited at [#sl-100]
      "#{aliases.first} #{syntax}"
    end

    def api # goes away at [#030]
      @api ||= API::Binding.new self
    end

    def api_invoke *a
      api.invoke(* a)
    end

    def infostream # visit at [#034]
      if parent
        parent.infostream
      else
        fail("where is infostream for #{self.class}")
      end
    end

    def on_no_action_name
      full_action_name_parts # #todo
    end

  protected

    def initialize
      on_no_config_dir do |e|

        emit :error, "couldn't find #{ e.touch!.dirname } in this or any #{
          }parent directory: #{ e.from.pretty }"

        emit :info, "(try #{ pre( "#{ root_runtime.program_name } #{
          CLI::Actions::Init.invocation_syntax }" ) } to create it)"

      end

      on_info  do |e| e.message = "#{runtime.program_name} #{
                                action_name}: #{ e.message}"
               end
      on_error do |e|
                       msg = format_error e
                       add_invalid_reason msg
               end

      on_all   do |e|
                       parent_runtime.emit(e) unless e.touched?
               end
    end

    def action_name # re-evalted at [#033]
      self.class.action_name
    end

    def format_error event # [#036]
      event.tap do |e|
        if runtime.parent
          subj, verb, obj = [runtime.parent.program_name, aliases.first, runtime.aliases.first]
        else
          subj, verb = [runtime.program_name, aliases.first]
        end
        e.message = "#{subj} failed to #{verb}#{" #{obj}" if obj}: #{e.message}"
      end
    end

    def full_action_name_parts # goes away as [#033]
      a = [aliases.first]
      root_id = root_runtime.object_id
      current = self
      loop do
        root_id == current.runtime.object_id and break
        a.push(( current = current.runtime).aliases.first)
      end
      a.reverse
    end

    def runtime # re-evaluated at [#034]
      parent # their api to ours [#018]
    end

    def parent_runtime # re-evaluated at [#034]
      parent # [#018]
    end

    def text_styler # [#038]
      parent.text_styler
    end
  end


  module CLI::NamespaceModuleMethods
    include Bleeding::NamespaceModuleMethods
    def build runtime
      CLI::NamespaceRuntime.new(self).build(runtime)
    end
  end


  class CLI::NamespaceRuntime < Bleeding::NamespaceInferred
    include CLI::Action::InstanceMethods
    def emit *a # quickfix near [#023]
      parent.emit(* a)
    end
    def infostream
      parent.infostream
    end
    def runtime # addressed at [#034]
      parent
    end
    def text_styler
      parent.text_styler
    end
  end
end
