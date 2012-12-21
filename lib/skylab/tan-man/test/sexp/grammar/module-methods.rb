module Skylab::TanMan::TestSupport::Sexp
  module Grammar::ModuleMethods
    extend ::Skylab::MetaHell::Let

    let :fixtures_dir_path do
      dir_pathname.join('../fixtures').to_s
    end

    let :grammars_module do
      to_s.split('::')[0..-2].reduce(::Object) { |m, k| m.const_get k, false }
    end
  end
end
