module Skylab::Snag

  class API  # see [#006]

    class << self
      def manifest_file
        MANIFEST_FILE__
      end

      def max_num_dirs_to_search_for_manifest_file
        MAX_NUM_DIRS_TO_SEARCH_FOR_MANIFEST_FILE__
      end
    end

    MANIFEST_FILE__ = 'doc/issues.md'.freeze

    MAX_NUM_DIRS_TO_SEARCH_FOR_MANIFEST_FILE__ = 15  # wuh-evuh

    module Actions

      def self.name_function  # #note-25
      end

      Autoloader_[ self, :boxxy ]
    end

    Client = self
    class Client

      @setup = nil  # #open [#050] this is not the way

      class << self

        attr_reader :setup

        alias_method :setup_ivar, :setup

        def setup f
          @setup and fail "won't stack (or queue) setups"
          @setup = f
          nil
        end

        def setup_delete
          x = @setup
          @setup = nil
          x
        end
      end

      def initialize app_module
        @app_module = app_module
        @max_num_dirs_to_search_for_manifest_file = nil
        @manifest_cache_h = {}
        API::Client.setup_ivar and API::Client.setup_delete[ self ]
      end

      attr_writer :max_num_dirs_to_search_for_manifest_file

      def call * a, & p
        new_invocation.with_a_and_p( a, p ).execute
      end

      def new_invocation
        Invocation__.new self
      end

      def build_action_via_name_and_p normal_name, p
        _cls = lookup_some_action_class_via_normal_name normal_name
        _cls.new p, self
      end

      def build_action_via_name normal_name
        _cls = lookup_some_action_class_via_normal_name normal_name
        _cls.new self
      end

      def lookup_some_action_class_via_normal_name normal_name
        Autoloader_.const_reduce normal_name, self.class::Actions
      end

      def models
        @models ||= API::Models__.new self, @app_module::Models
      end

      # ~ business

      def manifest_file
        self.class.manifest_file
      end

      def max_num_dirs_to_search_for_manifest_file
        @max_num_dirs_to_search_for_manifest_file ||
          self.class.max_num_dirs_to_search_for_manifest_file
      end
    end

    class Invocation__

      def initialize _API_client
        @API_client = _API_client
      end

      def with_a_and_p a, p
        @x_a = a ; @p = p ; self
      end

      def execute
        normal_name = @x_a.shift
        if ::Hash.try_convert @x_a.first
          par_h = @x_a.shift
          @p ||= @x_a.pop
          @x_a.length.zero? or raise ::ArgumentError
        end
        action = bld_action_from_name_and_p normal_name, @p
        action and begin
          if par_h
            action.invoke par_h
          else
            action.invoke_via_iambic @x_a
          end
        end
      end

      def bld_action_from_name_and_p normal_name, p
        if p
          @API_client.build_action_via_name_and_p normal_name, p
        else
          @API_client.build_action_via_name normal_name
        end
      end
    end

    class Models__

      def initialize _API_client, mod
        @API_client = _API_client
        @module = mod ; sc = singleton_class
        scan = mod.entry_tree.to_stream  # go deep into [cb] API
        while normpath = scan.gets
          name_i = normpath.name_i
          sc.send :define_method, :"#{ name_i }s", bld_reader( name_i )
        end
        @cache_h = {}
      end

      # names of methods (public or private) cannot ever end in the letter 's'

      attr_reader :API_client

    private

      def bld_reader name_i
        -> &p do
          @cache_h.fetch name_i do
            silo = bld_shell name_i
            silo and @cache_h[ name_i ] = silo
          end
        end
      end

      def bld_shell name_i
        Autoloader_.const_reduce( [ name_i ], @module ).
          build_silo @API_client
      end
    end

    Event_Factory = -> digraph, chan_i, sender, ev  do
      ev
    end
  end
end
