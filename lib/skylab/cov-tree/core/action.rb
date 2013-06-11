module Skylab::CovTree

  module Core::Action
    def self.extended mod # good ol' [#sl-111]
      mod.extend Core::Action::ModuleMethods
      mod.send :include, Core::Action::InstanceMethods
    end
  end


  module Core::Action::ModuleMethods
    include Headless::Action::ModuleMethods

    methodize = Autoloader::Inflection::FUN.methodize

    define_method :local_normal_name do # ::Blah::Actions::Foo::X -> [:foo, :x]
      @local_normal_name ||= begin
        amn = actions_anchor_module.name
        0 == name.index( amn ) or fail 'sanity'
        rest = name[ (amn.length + 2) .. -1 ]
        rest.split( '::' ).map { |s| methodize[ s ] }
      end
    end
  end


  module Core::Action::InstanceMethods
    include Core::SubClient::InstanceMethods

  protected

    def local_normal_name
      self.class.local_normal_name
    end
  end
end
