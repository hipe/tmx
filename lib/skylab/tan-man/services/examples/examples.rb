module ::Skylab::TanMan

  class Services::Examples

    extname = '.dot'

  public

    def example                   # get the value from config
      fetch services.config.fetch('example') { 'digraph.dot' }
    end

    def fetch basename
      box.fetch basename
    end

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
        pathname = box_dir_pathname.join name
        r = try[ pathname ]
        if ! r and '' == pathname.extname
          r = try[ pathname.sub_ext extname ]
        end
        r
      end.call
      if found
        result = found.relative_path_from box_dir_pathname
      else
        a = tries.map(& :basename)
        b = box_dir_pathname.children.map(& :basename)
        msg = "not found: #{ a.join ', ' }. Known examples: (#{ b.join(', ') })"
        result = error[ msg ]
      end
      result
    end

  protected

    def box
      TanMan::Examples
    end

    def box_dir_pathname
      box.dir_pathname
    end
  end
end
