module Skylab::CovTree

  module Core::Action
    def self.extended mod # good ol' [#sl-111]
      mod.extend Core::Action::ModuleMethods
      mod.send :include, Core::Action::InstanceMethods
    end
  end


  module Core::Action::ModuleMethods

    methodify = Autoloader::Inflection::FUN.methodify

    define_method :normalized_name do # ::Blah::Actions::Foo::X -> [:foo, :x]
      @normalized_name ||= begin
        amn = self::ANCHOR_MODULE.name
        0 == name.index( amn ) or fail 'sanity'
        rest = name[ (amn.length + 2) .. -1 ]
        rest.split( '::' ).map { |s| methodify[ s ] }
      end
    end
  end


  module Core::Action::InstanceMethods
    include Core::SubClient::InstanceMethods

  protected

    def normalized_name
      self.class.normalized_name
    end
  end
end
