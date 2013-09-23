module ::Skylab::TanMan

  class Services::Starters::Starters

    def starter                   # get the value from config
      fetch services.config.fetch 'starter' do 'holy-smack.dot' end
    end

    def fetch basename
      box_module.fetch basename
    end

    def normalize name, error_info_hash_p
      tries = []
      found = -> do
        try = -> p do
          if p.exist?
            p
          else
            tries.push p
            nil
          end
        end
        pathname = box_module_dir_pathname.join name
        r = try[ pathname ]
        if ! r and '' == pathname.extname
          r = try[ pathname.sub_ext EXTNAME__ ]
        end
        r
      end.call
      if found
        res = found.relative_path_from box_module_dir_pathname
      else
        a = tries.map(& :basename )
        b = get_scanner.map( & :basename )
        res = error_info_hash_p[
          message:
            "not found: #{ a.join ', ' }. Known starters: (#{ b.join ', ' })",
          valid_names: b.map(& :to_s )
        ]
      end
      res
    end
    #
    EXTNAME__ = '.dot'.freeze

    def get_scanner
      p = -> do
        fly = Fly__.new box_module_dir_pathname
        d = -1 ; last = (( cx = box_module_dir_pathname.children )).length - 1
        (( p = -> do
          if last == d
            p = MetaHell::EMPTY_P_
            nil
          else
            fly.set cx[ d += 1 ]
          end
        end )).call
      end
      Scanner__.new do p.call end
    end
    #
    class Fly__
      def initialize base_pn
        @base_pn = base_pn
      end
      def set pn
        @pn = pn
        self
      end
      def basename
        @pn.basename
      end
      def label
        @pn.relative_path_from( @base_pn ).to_s
      end
    end
    #
    class Scanner__ < ::Proc
      alias_method :gets, :call
      def map &p
        a = [ ] ; x = nil
        a << p[ x ] while (( x = gets ))
        a
      end
      def to_a
        map( & MetaHell::IDENTITY_ )
      end
    end

  private

    def box_module_dir_pathname
      box_module.dir_pathname
    end

    def box_module
      TanMan::Starters
    end

  end
end
