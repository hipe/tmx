# allocation table

• this is the most extreme yet manifestation of the [#ts-001] convention.

• there will be a max of 100 nodes at this node, 00-99

• the first 10 (00-09) are for high-level, essential concepts.
  (for now, only the meta-components.)

• the next 50 (10-59) are for real nodes defined in the filesystem
  at the corresponding asset node (the top of the sidesystem)

  • the first 25 (10-34) are reserved for more unit-test-like tests
    that test things like models

    • the first 12 (10-21) are for those not related to operations

    • the remaining 13 (22-34) can be related to operations

  • the remaining 25 (35-59) are for the rest (like the important
    sub-API concerns like reflection, and their subsidiaries)

    • the first 12 (35-46) are for the main things (reflection, interp)

    • the remaining 13 (47-59) are for subsidiaries

      • the first 6 are (47-52).
      • the second 7 are (53-59) any that use the above.

• the remaining 40 (60-99) are for whatever non-real nodes..
