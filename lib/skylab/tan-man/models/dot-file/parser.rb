require 'skylab/treetop-tools/core'

module Skylab::TanMan
  Models::DotFile::Sexp = ::Skylab::TanMan::Sexp
  module Models::DotFile::Parser end
  module Models::DotFile::Parser::InstanceMethods
    include ::Skylab::TreetopTools::Parser::InstanceMethods
    ENTITY_NOUN_STEM = 'dot file'
  protected
    def load_parser_class
      ::Skylab::TreetopTools::Parser::Load.new(
        ->(o) do
          o.force_overwrite!
          o.generated_grammar_dir '../../../../../tmp'
          o.root_for_relative_paths ::File.expand_path('..', __FILE__)
          o.treetop_grammar 'dot-language.treetop'
        end,
        ->(o) do
           o.on_info { |e| info "#{em '*'} #{e}" }
           o.on_error { |e| fail("failed to load grammar: #{e}") }
        end
      ).invoke
    end
  end
end
