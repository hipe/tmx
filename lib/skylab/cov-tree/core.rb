require_relative '..'
require 'skylab/test-support/core'  # and headless
require 'skylab/porcelain/core'  # wicked old ways

module Skylab::CovTree

  Autoloader   = ::Skylab::Autoloader
  CovTree      = self
  Headless     = ::Skylab::Headless # NLP::EN::Methods
  MetaHell     = ::Skylab::MetaHell
  Porcelain    = ::Skylab::Porcelain # legacy.rb, TiteColor, Tree
  PubSub       = ::Skylab::PubSub
  TestSupport  = ::Skylab::TestSupport  # `_spec_rb`

  extend MetaHell::Autoloader::Autovivifying::Recursive # we use Svcs now below

  module Core
    extend MetaHell::Autoloader::Autovivifying::Recursive # b/c this file req'd
  end

  o = { }

  glob_to_rx = o[:glob_to_rx] = -> glob do # a hack
    scn = CovTree::Services::StringScanner.new glob
    out = []
    until scn.eos?
      if scn.scan(/\*/)
        out.push '(.*)'
      elsif s = scn.scan(/[^\*]+/)
        out.push "(#{ ::Regexp.escape s })"
      else
        fail "Unexpected rest of string (don't use '**'): #{ scn.rest.inspect }"
      end
    end
    out.join ''
  end

  srbg = "*#{ TestSupport::FUN._spec_rb[] }"

  globs = o[:globs] = {
    'features' => '*.feature',
    'spec'     => srbg,
    'test'     => srbg
  }

  o[:stop_rx] = Headless::CLI::PathTools::FUN.stop_rx   # matches root pathnames meh

  o[:test_basename_rx] =
    %r{ ^ (?: #{ globs.values.uniq.map { |x| glob_to_rx[ x ] }.join '|' } ) $ }x

  test_dir_names = o[:test_dir_names] = %w(test spec features)

  def test_dir_names.string # kinda goofy
    "[#{ join '|' }]"
  end

  FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze


end
