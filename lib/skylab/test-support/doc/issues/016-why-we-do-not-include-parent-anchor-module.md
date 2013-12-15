# why we do not include parent anchor module :[#016]

*note*: we do *not* include the parent_anchor_module itself
into this client anchor_module. if you do, with our chosen naming
convention (which seems vital and fixed at this point)
it will have the effect of having the test-support
anchor modules masking the client modules of the same name:

  e.g.:  MyApp::Mod_1                      # business logic for your app
         MyApp::Mod_1::Mod_A               # this holds some sub-content
         MyApp::TestSupport                # your root test support mod
         MyApp::TestSupport::Mod_1         # test support for same
         MyApp::TestSupport::Mod_1::Mod_A  # test support for same


if you are either directly "inside" TS::Mod_1::Mod_A or you are in
a module that has included same, and you say `Mod_1`, which Mod_1
do you mean?  it's arguably bad design to mean T_S::Mod_1
(so confusing!) but that's what you would get if anchor modules
included their parent anchor modules. i bet it's crystal clear now,
eh!?

if you want constants to be "inherited down" from one anchor module
to another, the place to do that is e.g. in a module called CONSTANTS
that resides in your anchor module. you would then include that
CONSTANTS module in your I_M or your M_M as appropriate. in flux!
this way it is a) opt-in whether which modules at a particular node
(file) are getting which constants in their chain and b) for a given
product which (er) constants should *be* in CONSTANTS in the first
place.

(now, experimentally, we are doing the above)
