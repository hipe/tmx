module Skylab::Snag

  module API

    # For no good reason API (the module) is the home of low-level,
    # bootstrappy, zero-config-style config.

    manifest_path = 'doc/issues.md'.freeze # etc

    define_singleton_method :manifest_path do manifest_path end

    max_num_dirs_to_search_for_manifest_file = 15 # wuh-evuh

    define_singleton_method :max_num_dirs_to_search_for_manifest_file do
      max_num_dirs_to_search_for_manifest_file
    end

    module Actions
      def self.name_function ; end
      Autoloader_[ self, :boxxy ]
    end
  end

  class API::Client

    include Snag_::Core::SubClient::InstanceMethods

    @setup = nil                  # experimental hackery for .. well ..

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

    def initialize client
      @max_num_dirs_to_search_for_manifest_file = nil
      API::Client.setup_ivar and API::Client.setup_delete[ self ]
      super client
    end

    def build_action normalized_action_name
      # keeping for #posterity, primordial boxxy:
      #path.reduce(self.class) { |m, s| m.const_get(constantize(s)) }.new(self)
      Autoloader_.const_reduce( normalized_action_name, API::Actions ).
        new self
    end

    # getters for *persistent* models *objects* (think daemons):

    def find_closest_manifest from_path, error
      res = nil
      begin
        mp = find_closest_manifest_path from_path, error
        mp or break( res = mp )
        mp.absolute? or fail 'sanity'
        manny = ( @manifest_cache ||= { } ).fetch( mp.to_s ) do |path| # ofuck
          man = Snag_::Models::Manifest.new mp
          man
        end
        res = manny
      end while nil
      res
    end

    manifest_path = API.manifest_path

    define_method :find_closest_manifest_path do |from_path, error|
      res = nil
      begin
        if from_path
          pn = ::Pathname.new from_path
          pn.relative? and pn = pn.expand_path
        else
          pn = ::Pathname.pwd
        end
        found = nil
        num_dirs_searched = 0
        seen = []
        max = max_num_dirs_to_search_for_manifest_file
        loop do
          if num_dirs_searched >= max
            break
          end
          num_dirs_searched += 1
          try = pn.join manifest_path
          if try.exist?
            found = try
            break
          end
          dirname = pn.dirname
          if pn == dirname        # we have reached the last nerk of a relative
            break                 # or absolute pathname.
          end
          seen.push pn.basename.to_s
          pn = dirname
        end
        if ! found
          rev = seen.reverse
          a = [ * ::Array.new( rev.length, '..' ), * rev ]
          tot = " (#{ rev.length } total)"
          error[ "manifest not found, looked for #{ manifest_path } #{
            }in each dir#{tot}: #{ a.join '/' }#{ a.empty? ? '(none)' : '/' }" ]
          break
        end
        res = found
      end while nil
      res
    end

    attr_writer :max_num_dirs_to_search_for_manifest_file

  private

    def max_num_dirs_to_search_for_manifest_file
      @max_num_dirs_to_search_for_manifest_file ||
        API.max_num_dirs_to_search_for_manifest_file
    end
  end
end
