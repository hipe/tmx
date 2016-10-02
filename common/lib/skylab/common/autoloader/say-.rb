module Skylab::Common

  module Autoloader

    module Say_

      # #todo - many of these migrated here during the rewrite but etc

      Ambiguous = -> const_a, name, mod do
        "unhandled ambiguity - #{ name.as_slug.inspect } resolves to #{
          }#{ mod.name }::( #{ const_a * ' AND ' } )"
      end

      Needs_dir_path = -> mod do
        "needs `dir_path`: #{ mod }"
      end

      Not_idempotent = -> mod do  # #not-idemponent
        "this operation is not idempotent. autoloader will not enhance #{
          }an object that already responds to 'dir_path': #{ mod }"
      end

      Not_in_file = -> path, const_s, mod do
        "#{ mod.name }::#{ const_s } #{
         }must be but does not appear to be defined in #{ path }"
      end

      Scheme_change = -> now_sym, then_sym, mod do
        "inconsistent const casing - #{
         }the filesystem node that resolves as an isomorph #{
          }to this const has already been associated with a different const. #{
           }make sure the loaded asset files define the intended consts #{
            }and/or change code so that it only uses the correct const names - #{
             }#{ mod }::( (then:) #{ then_sym } (now:) #{ now_sym } )"
      end

      Uninitialized_constant = -> name, mod do  # const missing

        _path_like = ::File.join mod.dir_path, "#{ name.as_slug }[#{ EXTNAME }]"

        "uninitialized constant #{ mod.name }::#{ name.as_const } #{
           }and no directory[file] #{ _path_like }"
      end

      Wrong_const_name = -> x do
        "wrong constant name #{ x }"
      end

    end
  end
end
# #history: broke out of toplevel sidesystem file
