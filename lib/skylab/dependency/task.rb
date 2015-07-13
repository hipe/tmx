module Skylab::Dependency

  class Task < Home_.lib_.slake::Task

    attribute_metadata_class do
      def [] k ; fetch( k ) { } end # soften it
    end
    meta_attribute :boolean
    meta_attribute :default
    meta_attribute :from_context
    meta_attribute :pathname
    meta_attribute :required

    attr_accessor  :context
    attr_reader :invalid_reason

    Callback_[ self, :employ_DSL_for_digraph_emitter ]   # child classes decide what to call_digraph_listeners

    include Home_.lib_.path_tools.instance_methods_module

    define_method :stylize, Home_.lib_.brazen::CLI::Styling::Stylize

    def hi str ; stylize str, :strong, :green end

    def no str ; stylize str, :strong, :red   end

    def initialize(* a )
      super
      if_unhandled_streams :fail
      NIL_
    end

    def valid? # [#hl-047]

      _req_i_a = self.class.attributes.each_pair.reduce [] do | m, (k, atr) |
        if atr[ :required ]
          m.push k
        end
        m
      end

      miss_i_a = _req_i_a.select do | k |
        send( k ).nil?
      end

      if miss_i_a.length.zero?
        true
      else
        a = miss_i_a

        @invalid_reason = "#{ name } task missing required attribute#{
          }#{ 's' if a.length != 1 }: #{ a * ', ' }"

        false
      end
    end

    def build_digraph_event s, i, _esg
      Textual_Old_Event_.new s, i
    end
  end

  class << Task
    def on_boolean_attribute name, meta
      define_method("#{name}?") { send(name) } # alias_method misses future hacks
    end

    def on_default_attribute name, meta
      alias_method "#{name}_before_default", name
      define_method(name) do
        v = send("#{name}_before_default")
        v.nil? or return v
        meta[:default]
      end
    end

    def on_from_context_attribute name, meta
      alias_method "#{name}_before_from_context", name
      define_method(name) do
        if instance_variable_defined?("@#{name}") # verrry experimental
          return instance_variable_get("@#{name}")
        end
        if @context.key?(name)
          return @context[name]
        end
        send "#{name}_before_from_context"
      end
    end

    def on_pathname_attribute name, meta
      before = "#{name}_before_pathname"
      alias_method before, name
      define_method(name) do
        if pn = send(before) and ! pn.kind_of?(::Pathname)
          instance_variable_set("@#{name}", pn = ::Pathname.new(pn))
        end
        pn
      end
    end

    def _mutex_fail ks, ks2
      ks.length > ks2.length and ks2.push('("check" and or "update")')
      ks2.map! { |e| e.kind_of?(::String) ? e : "\"#{e.to_s.gsub('_', ' ')}\"" }
      _err "#{ks2.join(' and ')} are mutually exclusive.  Please use only one."
      false
    end

    def dry_run?            ; request[:dry_run]            end

    def optimistic_dry_run? ; request[:optimistic_dry_run] end

    def _view_tree
      raise "needs testing and re-development (very old)"  # #todo:meh
      trav = Home_::Library_::Tree::Locus.new
      color = ui.out.tty?
      trav.traverse self do |card|
        ui.out.puts "#{ loc.prefix card }#{
          }#{ card.node.styled_name color: color }#{
          } (#{ card.node.object_id.to_s 16 })"
      end
    end
  end
end
