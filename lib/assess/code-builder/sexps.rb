require 'assess/util/strict-attr-accessors'
require File.dirname(__FILE__)+'/file-sexp.rb'
module Hipe
  module Assess
    module CodeBuilder

      class ModuleSexp < Sexp
        include ModuleySexp
        undef_method :method_missing # too much pita
        def self.build name, &block
          name_sexp = CodeBuilder.module_name_sexp name
          thing = new(:module, name_sexp, s(:scope, s(:block)))
          yield(thing) if block_given?
          thing
        end
      end

      class ClassSexp < ModuleSexp
        include ClassySexp

        def self.build name_sym, extends_str, &block
          extends_str = extends_str.to_s
          if ""==extends_str
            extends_sexp = nil
          else
            extends_sexp = CodeBuilder.parser.process(extends_str)
          end
          name_sexp    = CodeBuilder.module_name_sexp name_sym
          thing = new(:class, name_sexp, extends_sexp, s(:scope, s(:block)))
          yield(thing) if block_given?
          thing
        end
      end
    end
  end
end
