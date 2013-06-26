module Skylab::Treemap
  module Plugins::FooBar
    extend MetaHell::Autoloader::Autovivifying
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
    extend MetaHell::Autoloader::Autovivifying
    MetaHell::Boxxy[ self ]
  end
end
