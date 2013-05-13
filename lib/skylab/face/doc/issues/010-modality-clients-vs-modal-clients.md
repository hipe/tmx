# modality client vs modal clients

At the time of this writing there is an instance method
`Face::CLI::Namespace#modal_client_for_api_call`. its purpose is to determine
what the API will use during the isomorphic [#fa-015] call for its modality
hookbacks, e.g event wiring and services.

for small, tight applications life might be easier to have the modal client
in such moments be the modality client (e.g the CLI Client). however down the
road it may prove useful to conceptulize the whole rigging as a deep tree, with
certain nodes exhibiting certain behavior and so on; so we leave room for that
for the e.g CLI Action class to override this and result in something
else, like itself.

**however however**, we should remember that command trees are really a
cosmetic UI construct, so if you ever try something like the above, please
do so only if it is within this scope. an example would be useful but we
can't think of one.
