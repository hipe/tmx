require Hipe::CssConvert::ROOT + '/treetop-tools'

module Hipe
  module CssConvert
    module Grammar
      module Directives
        S = ::Hipe::CssConvert::TreetopTools::Sexpesque
      end
    end
  end
end

class Hipe::CssConvert::DirectivesParser
  ROOT = ::Hipe::CssConvert::ROOT
  class RuntimeError < ::RuntimeError; end
  class << self
    def require_local_treetop
      Object.const_defined?(:Treetop) and return
      require 'rubygems' # still use ployglot as found by rubygems
      $:.unshift(File.dirname(File.dirname(ROOT))+'/vendor/lib/treetop/lib')
        # use treetop in vendor/lib, not the one in
        # rubygems/rvm/gemspec/whatever, in case etc.. @todo
      require 'treetop'
    end
  end
  def initialize ctx
    @c = ctx
  end
  def parse_file path
    path && File.exist?(path) or
      return error("directives file not found: #{path.inspect}")
    parse_string File.read(path)
  end
  def parse_string whole_string
    resp = parser.parse(whole_string)
    if resp.nil?
      rsn = parser.failure_reason || "Got nil from parse without reason!"
      @c.err.puts rsn
      nil
    else
      resp.tree
    end
  end
private
  def error msg
    raise RuntimeError.new(msg)
  end
  def parser_class
    @parser_class ||= begin
      self.class.require_local_treetop
      Hipe::CssConvert::TreetopTools.load_parser_class do |o|
        o.root_dir ROOT
        o.generated_grammar_dir @c[:tmpdir_relative]
        o.treetop_grammar 'directives-parser/common.treetop'
        o.treetop_grammar 'directives-parser/directives.treetop'
        o.force_overwrite! if @c[:force_overwrite]
        o.enhance_parser_with ::Hipe::CssConvert::TreetopTools::ParserExtlib
        o.use_ui @c
      end
    end
  end
  def parser
    @parser ||= parser_class.new
  end
end
