[#040]       operator branch via directory ..
       #open [#here.F]: clean this up after an incubation period

[#039]
             [#here.1] track all similar proxy classes for acting like a writable IO
[#038]       [ the "readable writable" legacy system recorder ]
[#037]       [ the snippet based legacy system recorder ]
[#036]       the new recording proxy
[#035]       a sixth system double
[#034]       [ hack guess module tree ]
[#033] #open feature islands

[#032]       track events that might DRY (one here)
             :[#here.2]: an event related to writing files
             ( #was: alternative (simplified) implementations of stubbed FS )
             ( #moved-to: [#027.2] )

[#031]       [ processes ]
[#030]       chunker & related
[#029]       [ OGDL ]
[#028]       [ stubbed system ]

[#027]       the stubbed filesystem narrative ..
             [#here.C]: tracks simplified implementations in this sidesystem
             [#here.2]: alternative implementations in universe (none here)

[#026]       [ mkdir p ]
[#025] #open "open2" (ancient) reconcile with IO-select (hl?)
[#024]       [ mocks ]

[#023]       diff & patch
             [#here.1]: diff
             [#here.2]: patch

       #open make sure these always work through a system conduit, i.e
             don't allow the production of diff or the application
             of patches merely through static methods.

[#022] #open #in-situ
[#021]       track a shared maneuver (stat)
[#020]       the tmpdir narrative
[#019]       #parent-node: [#016]



[#018]       [ walk ] #parent-node: [#009]
[#017]       the grep narrative ..
[#016]       the find narrative ..
[#015] #open stateful IO dry stub so that `close` is better
[#014]       [ IO mappers tee ] #parent-node: [#010]
[#013]       the IO line stream narrative #parent-node: [#010] ..

[#012]       [ IO interceptors filter ] #parent-node: [#010]

[#011] #open the file utils agent should emit oes #parent-node: [#009]

             separate but related, should FUC go away in lieu of [#009.A]?

[#010]       [ IO ]  ( #was: #moved-to: [#001] )

[#009]       #parent-node: [#001]. the filesystem narrative ..

[#008]       coverage assets & liabilities & similar

             [#here.{2-4}]: borrow coverage

             [#here.1]: we're relying on the content of these two files
                        to be self-similar (cross referenced to [ts])
             ( #was: #in-situ hard-coded in-project tmpdir path! )

[#007]       track internal issues

             :[#here.A]: shallowify everything. the "services" idiom isn't
             valuable enough to justify itself. or maybe hack something for
             it like:
                 [sidesystem]/lib/skylab/system/bundle-1/service.rb
                 [sidesystem]/lib/skylab/system/bundle-2/service.rb

             ( #was: hack guess module tree )

[#006]       #track universal uses of `select`-style operations
[#005]       the path tools narrative ..
[#004]       #parent-node: [#010] the normalizers ..
[#003]       [ the FS byte upstream ID ]
[#002]       [ flock etc ]
[#001]       [ the README ]
