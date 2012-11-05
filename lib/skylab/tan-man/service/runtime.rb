module ::Skylab::TanMan
  module Services
    @dir_path = TanMan.dir_pathname.join('services').to_s
    extend MetaHell::Autoloader::Autovivifying::Recursive
    def self._const_missing_class
      Service::Load
    end
  end
  class Service::Load <
                    MetaHell::Autoloader::Autovivifying::Recursive::ConstMissing
    let :file_pathname do
      stem = pathify const
      mod_dir_pathname.join "#{stem}/#{stem}#{EXTNAME}"
    end
  end
  class Service::Runtime
    extend MetaHell::Let

  protected
    def initialize
      gsub_rx = /-/
      white_rx = /\A[-a-z]+\z/
      methodify_f = ->(s) do
        white_rx =~ s or fail("sanity - bad service dir name #{s}")
        s.gsub gsub_rx, '_'
      end
      sc = singleton_class
      TanMan::Services.dir_pathname.children.each do |pn|
        sc.let( methodify_f[ pn.basename.to_s ] ) do
          _build pn
        end
      end
    end
    def _build pn
      _const = ::Skylab::Autoloader::Inflection.constantize pn.basename.to_s
      _class = Services.const_get _const
      _class.new
    end
  end
end
