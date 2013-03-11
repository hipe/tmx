module Skylab::MyTree
  module Services
    h = { }
    define_singleton_method( :o ) { |const, block| h[const] = block }

    o :Find         , -> { require_relative 'services/find'      }
    o :Open3        , -> { require 'open3'      ; ::Open3        }
    o :OptionParser , -> { require 'optparse'   ; ::OptionParser }
    o :Set          , -> { require 'set'        ; ::Set          }
    o :Shellwords   , -> { require 'shellwords' ; ::Shellwords   }
    o :Time         , -> { require 'time'       ; ::Time         }

    define_singleton_method :const_missing do |k|
      x = h.fetch( k ).call
      if true == x
        if const_defined? k, false
          const_get k, false
        else
          super k
        end
      else
        const_set k, x
      end
    end
  end
end
