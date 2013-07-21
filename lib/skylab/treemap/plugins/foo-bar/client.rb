module Skylab::Treemap

  module Plugins::FooBar
    MetaHell::Autoloader::Autovivifying[ self ]
  end

  class Plugins::FooBar::Client
    def load_attributes_into x
    end

    def load_options_into x
    end
  end

  module Plugins::FooBar::CLI
  end

  module Plugins::FooBar::CLI::Actions
    MetaHell::Autoloader::Autovifiying[ self ]
    MetaHell::Boxxy[ self ]
  end
end
