module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Generate

          Parameter_Functions_::Output_filename = -> gen, val_x, & oes_p do

            # our scope is decidedly limited to doing simple string arithmetic
            # on the received path using the argument string. we eschew use of
            # the filesystem and environment, which introduce coupling that is
            # not worth the cost given our scope. in this typical use case, we
            # substitute the basename of the received path with the argument:
            #
            #     received path and argument: "/foo/bar.x", "baz.x"
            #     result:                     "/foo/baz.x"
            #
            # also we support the use of the ".." operator. ordinarily someone
            # would use `::File#expand_path` to provide this behavior; however
            # this method does not work as documented: if for the `dir_string`
            # argument a relative path is provided, it itself is not used as a
            # starting point (contrary to the documentation); rather it too is
            # subject to expansion using the current working directory of the
            # process.
            #
            # to avoid all this we us a library function to do the arithmetic.


            _current_path = gen.output_path

            _dirname = ::File.dirname _current_path

            _real_a = _dirname.split FILE_SEP_

            _rel_a = val_x.split FILE_SEP_

            result_a = TestSupport_.lib_.basic::Pathname.
              expand_real_parts_by_relative_parts( _real_a, _rel_a, & oes_p )

            result_a and begin

              _new_path = result_a.join FILE_SEP_

              gen.receive_output_path _new_path
            end
          end

      end
    end
  end
end
