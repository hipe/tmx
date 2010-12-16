require File.expand_path('../../lib/css-convert', __FILE__)

module Hipe::CssConvert::ExampleHelperMethods
  def new_cli
    Hipe::CssConvert.cli.buffered!
  end
  def fixture tail
    File.join('spec/fixtorros', tail)
  end
end