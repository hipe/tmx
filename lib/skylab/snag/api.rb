module Skylab::Snag
  module API
    # For no good reason API (the module) is the home of low-level,
    # bootstrappy, zero-config-style config.

    manifest_file_name = 'doc/issues.md'.freeze # etc
    define_singleton_method :manifest_file_name do manifest_file_name end

    define_singleton_method :max_num_dirs_to_search_for_manifest_file do
      15 # wuh-evuh
    end
  end

  class API::Client
    include Snag::Core::SubClient::InstanceMethods


    constantize = Autoloader::Inflection::FUN.constantize

    define_method :action do |*path|   # create a new instance of the action
      # keeping for #posterity, primordial boxxy:
      #path.reduce(self.class) { |m, s| m.const_get(constantize(s)) }.new(self)

      klass = path.reduce(API::Actions) { |m, x| m.const_get constantize[ x ] }
      o = klass.new self
      o
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


    max_num_dirs_to_search = API.max_num_dirs_to_search_for_manifest_file
    manifest_file_name = API.manifest_file_name

    define_method :find_closest_manifest_path do |error|
      res = nil
      begin
        pn = ::Pathname.new Snag::Services::FileUtils.pwd
        found = nil
        num_dirs_searched = 0
        seen = []
        loop do
          if num_dirs_searched >= max_num_dirs_to_search
            break
          end
          num_dirs_searched += 1
          try = pn.join manifest_file_name
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
          error[ "manifest not found, looked for #{ manifest_file_name } #{
            }in each dir#{tot}: #{ a.join '/' }#{ a.empty? ? '(none)' : '/' }" ]
          break
        end
        res = found
      end while nil
      res
    end

  protected

    def initialize modality_client
      _snag_sub_client_init! modality_client
    end
  end
end
