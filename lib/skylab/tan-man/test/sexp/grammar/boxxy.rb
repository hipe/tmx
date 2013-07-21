module ::Skylab::TanMan::TestSupport

  module Sexp::Grammar::Boxxy # [#023]
    # ad-hoc one-off for autoloading our test grammars on-demand

    include CONSTANTS  # necessary to see m.h below

    include ::Skylab::Autoloader::Methods # does not #trigger

    def self.extended mod
      clr = caller[0]
      mod.module_exec do
        @tug_class = MetaHell::Autoloader::Autovivifying::Recursive::Tug
        init_autoloader clr
      end
      nil
    end

    -> do

      rx = /\AGrammar(?<num>[0-9]+)(?:_(?<rest>.+))?\z/

      pathify = ::Skylab::Autoloader::FUN.pathify

      define_method :const_missing do |const|
        md = rx.match const.to_s
        if ! md
          fail "oops - #{ const.inspect }"
        else
          num, rest = md.captures
          stem = [ num , ( pathify[ rest ] if rest ) ].compact.join '-'
          pathname = dir_pathname.join "#{ stem }/client"
          load pathname.to_s
          if ! const_defined? const, false
            raise ::NameError, "where is #{ self }::#{ const }?"
          else
            mod = const_get const, false
            mod.instance_variable_set :@dir_pathname, pathname
            mod
          end
        end
      end
    end.call
  end
end
