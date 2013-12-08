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
  end

  class API::Client

    include Snag::Core::SubClient::InstanceMethods

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

    def build_action normalized_action_name
      # keeping for #posterity, primordial boxxy:
      #path.reduce(self.class) { |m, s| m.const_get(constantize(s)) }.new(self)
      API::Actions.const_fetch( normalized_action_name ).new self
    end

    # getters for *persistent* models *objects* (think daemons):

    def find_closest_manifest error
      res = nil
      begin
        mp = find_closest_manifest_path error
        mp or break( res = mp )
        mp.absolute? or fail 'sanity'
        manny = ( @manifest_cache ||= { } ).fetch( mp.to_s ) do |path| # ofuck
          man = Snag::Services::Manifest.new mp
          man
        end
        res = manny
      end while nil
      res
    end

    manifest_path = API.manifest_path

    define_method :find_closest_manifest_path do |error|
      res = nil
      begin
        pn = ::Pathname.pwd
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

    def initialize modality_client
      @max_num_dirs_to_search_for_manifest_file = nil
      super modality_client
      API::Client.setup_delete[ self ] if API::Client.setup_ivar
    end

    def max_num_dirs_to_search_for_manifest_file
      @max_num_dirs_to_search_for_manifest_file ||
        API.max_num_dirs_to_search_for_manifest_file
    end
  end
end
