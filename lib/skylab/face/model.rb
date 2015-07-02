module Skylab::Face

  module Model

    # is it a good idea to extend the plugin library?  let's just see..

    def self.enhance mod, & blk
      cnd = Shell_.new( fsh = Metaservices_.new )
      blk and cnd.instance_exec( & blk )
      fsh.flush mod
      nil
    end
  end

  class Model::Shell_ < Home_::Plugin::Shell_
    def do_memoize
      @story.do_memoize!
    end
    def do_not_memoize
      @story.do_not_memoize!
    end
  end

  class Model::Metaservices_ < Home_::Plugin::Metaservices_
    def self.do_memoize!
      const_set :DO_MEMOIZE_, true
    end
    def self.do_not_memoize!
      const_set :DO_MEMOIZE_, false
    end
    def self.do_memoize
      if const_defined? :DO_MEMOIZE_, false
        const_get :DO_MEMOIZE_, false
      end
    end
    def do_memoize
      self.class.do_memoize
    end
  end
end
