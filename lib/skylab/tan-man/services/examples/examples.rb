module ::Skylab::TanMan

  class Services::Examples

    extname = '.dot'

  public

    def example                   # get the value from config
      fetch services.config.fetch('example') { 'digraph.dot' }
    end

    def fetch basename
      box_module.fetch basename
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
        pathname = box_module_dir_pathname.join name
        r = try[ pathname ]
        if ! r and '' == pathname.extname
          r = try[ pathname.sub_ext extname ]
        end
        r
      end.call
      if found
        result = found.relative_path_from box_module_dir_pathname
      else
        a = tries.map(& :basename)
        b = box_module_dir_pathname.children.map(& :basename)
        msg = "not found: #{ a.join ', ' }. Known examples: (#{ b.join(', ') })"
        e = PubSub::Event.new :error, message: msg, valid_names: b.map(&:to_s)
        def e.to_s ; message end # ick sorry
        result = error[ e ]
      end
      result
    end

  protected

    def box_module
      TanMan::Examples
    end

    def box_module_dir_pathname
      box_module.dir_pathname
    end
  end
end
