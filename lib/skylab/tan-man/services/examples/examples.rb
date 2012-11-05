module ::Skylab::TanMan

  class Services::Examples
    EXTNAME = '.dot'
    def example
      fetch service.config.fetch('example') { 'digraph.dot' }
    end
    def fetch basename
      TanMan::Examples.fetch basename
    end
    def normalize name, &events_f
      e = Headless::Parameter::Definer.new do
        param :on_success, hook: true
        param :on_failure, hook: true
      end.new(& events_f)
      pn = Examples.dir_pathname.join(name)
      found = if pn.exist? then pn
      elsif '' == pn.extname && (pn2 = pn.sub_ext EXTNAME).exist? then pn2
      end
      if found then
        e.on_success.call found.relative_path_from(Examples.dir_pathname).to_s
        true
      else
        a = [pn, pn2].compact.map(&:basename)
        b = Examples.dir_pathname.children.map(&:basename)
        e.on_failure.call "not found: #{ a.join ', ' }. Known examples: (#{
          b.join(', ') })"
        false
      end
    end
  protected
  end
  module Examples end
  class << Examples
    dir_pathname = TanMan.dir_pathname.join 'examples'
    cache = { }
    define_method( :dir_pathname ) { dir_pathname }
    define_method :fetch do |stem|
      pathname = dir_pathname.join stem # it normalizes various paths
      cache[pathname.to_s] ||= TanMan::Template.from_pathname pathname
    end
    alias_method :[], :fetch
  end
end
