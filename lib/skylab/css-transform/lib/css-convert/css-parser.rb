module Hipe::CssConvert
  module CssParsing
    here = File.dirname(__FILE__)+'/css-parsing'
    Grammars.load "#{here}/common"
    Grammars.load "#{here}/css-file"
  end
  class CssParser < CssParsing::CssFileParser
    # we wrap it up just in case we want extra craps with it
  end
end
