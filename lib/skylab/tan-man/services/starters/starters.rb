module ::Skylab::TanMan

  class Services::Starters::Starters

    def starter                   # get the value from config
      fetch services.config.fetch 'starter' do 'holy-smack.dot' end
    end

    def fetch basename
      box_module.fetch basename
    end

    # `error` if one occurs will get called with a hash of metadata,
    # including one `message`.

    extname = '.dot'

    define_method :normalize do |name, error|
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
          r = try[ pathname.sub_ext extname ]
        end
        r
      end.call
      if found
        res = found.relative_path_from box_module_dir_pathname
      else
        a = tries.map(& :basename )
        b = box_module_dir_pathname.children.map(& :basename )
        res = error[
          message:
            "not found: #{ a.join ', ' }. Known starters: (#{ b.join ', ' })",
          valid_names: b.map(& :to_s )
        ]
      end
      res
    end

  private

    def box_module
      TanMan::Starters
    end

    def box_module_dir_pathname
      box_module.dir_pathname
    end
  end
end
