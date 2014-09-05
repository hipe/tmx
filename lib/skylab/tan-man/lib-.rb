module ::Skylab::TanMan

  module Services  # :+[#su-001]

    stdlib, subsys = ::Skylab::Subsystem::FUN.
      at :require_stdlib, :require_subsystem

    o = H_ = { }
    o[ :Basic ] = subsys
    o[ :Face ] = subsys
    o[ :JSON ] = -> _ { require 'json' ; ::JSON }
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :PP ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }
    o[ :Template ] =
      -> _ { ::Skylab::Subsystem::Subsystems_::Basic::String::Template }

    # #was-boxxy

    def self.const_missing c
      if (( p = self::H_[ c ] ))
        const_set c, p[ c ]
      else
        super
      end
    end

    # here are our special needs below - we have legitimate services that
    # are potentially long-running zero-config entities, with a zero-config
    # plugin architecture consisting of simply dropping files into the folder.

    class << self

      def services
        if const_defined? :SERVICE_CLIENT_
          self::SERVICE_CLIENT_
        else
          const_set :SERVICE_CLIENT_,
            Build_services_client_class_[ self, :Client_ ].new
        end
      end

      def config
        services.config
      end

      def tree
        services.tree
      end
    end

    Build_services_client_class_ = -> host, const do  # e.g Services, Client_
      kls = host.const_set const, ::Class.new
      host.dir_pathname.children( false ).each do |pn|
        stem = Autoloader::FUN::Methodize[ pn.sub_ext( '' ) ].intern
        ivar = :"@#{ stem }"
        i_a = ::Array.new ( pn.extname.empty? ? 2 : 1 ), stem
        kls.send :define_method, stem do
          if instance_variable_defined? ivar
            instance_variable_get ivar
          else
            instance_variable_set ivar, host.const_fetch( i_a ).new
          end
        end
      end
      kls
    end
  end
end
