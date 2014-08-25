module Skylab::Brazen

  class Model_

  class Action

    class << self

      attr_accessor :custom_inflection, :description_block, :is_promoted

      def name_function
        @nf ||= begin
          extend Lib_::Name_function_methods[]
          bld_name_function
        end
      end
    end

    include Brazen_::Model_::Entity  # so we can override its behavior near events

    Brazen_::Entity::Event::Merciless_Prefixing_Sender[ self ]  # experimental default

    include Interface_Element_Instance_Methdods__

    def initialize
    end

    def is_branch
    end

    def is_visible
      true
    end

    def to_even_iambic
      scn = get_property_scanner ; x_a = []
      while (( prop = scn.gets ))
        x_a.push prop.name.as_lowercase_with_underscores_symbol,
          instance_variable_get( prop.as_ivar )
      end
      x_a
    end

    def get_property_scanner
      props = self.class.properties
      if props
        props.to_value_scanner
      else
        Callback_::Scn.the_empty_scanner
      end
    end

    def resolve_any_executable_via_iambic_and_adapter x_a, adapter
      @client_adapter = adapter
      @error_count = 0
      process_iambic_fully x_a
      notificate :iambic_normalize_and_validate
      if @error_count.zero?
        adapter.executable_wrapper_class.new self, :execute
      end
    end

    def receive_missing_required_props ev
      receive_negative_event ev
    end

    def receive_error_event ev  # e.g ad-hoc normalization failure from spot [#012]
      ev_ = sign_event ev
      receive_negative_event ev_
    end

    def receive_negative_event ev
      @error_count += 1
      @client_adapter.receive_negative_event ev ; nil
    end

    private

    # ~

    def listener
      @listener ||= bld_listener
    end

    def bld_listener
      if self.class.const_defined? :Listener
        self.class::Listener.new @client_adapter, self.class
      else
        self
      end
    end

    # ~


    def execute
      ok = assert_workspace_exists
      ok and if_workspace_exists
    end

    def assert_workspace_exists
      _path = Brazen_::CLI::Property__.new :path, :argument_arity, :one
      Brazen_::Models_::Workspace.status [ :client, :_FOO_, :listener, self,
        :max_num_dirs, 1, :path, '.', :verbose, true, :prop, _path ]
    end

  public

    def receive_workspace_file_not_found ev
      receive_error_event ev
      UNABLE_
    end

    def receive_workspace_event ev
      receive_error_event ev
      UNABLE_
    end
  end
  end
end
