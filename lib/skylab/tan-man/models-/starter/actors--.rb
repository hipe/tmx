module Skylab::TanMan

  module Starters
    # recursive autoloader should set dir_pathname here *right after*
    # this file is loaded!
    #

    cache = { }


    # For all strings `stem`, normalize it to a joined path and result in
    # a template object representing the possible template file that is
    # there, without checking if the file exists. caches results.
    #
    define_singleton_method :fetch do |stem|
      pathname = dir_pathname.join stem # (it normalizes dotty paths)
      result = cache.fetch pathname.to_s do |path|
        cache[path] = TanMan::Services::Template.from_path path
      end
      result
    end

    singleton_class.send :alias_method, :[], :fetch

  end
end
