module ::Skylab::TanMan::TestSupport
  module Sexp::Grammar::Boxxy
    # ad-hoc one-off for autoloading our test grammars on-demand

    include ::Skylab::Autoloader::Inflection::Methods # pathify
    include ::Skylab::Autoloader::ModuleMethods # does not #trigger

    def self.extended mod
      extend ::Skylab::Autoloader::ModuleMethods # #trigger (maybe nec. later)
      mod._autoloader_extended! caller[0]
    end

    -> do
      rx = /\AGrammar(?<num>[0-9]+)(?:_(?<rest>.+))?\z/
      define_method :const_missing do |const|
        md = rx.match(const.to_s) or fail("oops: #{const}")
        num, rest = md.captures
        stem = [ num , ( pathify rest if rest ) ].compact.join('-')
        pathname = dir_pathname.join("#{stem}/client")
        load pathname.to_s
        if const_defined? const, false
          o = const_get const, false
          o.dir_path = pathname.sub_ext('').to_s
          o
        end
      end
    end.call
  end
end
