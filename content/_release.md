+++
title = "Release process"
weight = 20
+++


# Release process

Tasks that need to happen for a release:

## Preparation

* Open release issue with the Release tag and mention all issues and tickets
that will go on that release
(https://github.com/ipfs-cluster/ipfs-cluster/issues/620). It helps backtrack when
things happening from the issues.
* Write the changelog entry for the release (copy from previous) and commit to
  branch:
  * Summary of what's happening in the release
  * List of features, bugs
  * Configuration changes and upgrades notices (note comment at the bottom of
  the file about how to write @issuelinks and replace them with sed)
* PR to the website with all the necessary documentation changes
  * Special attention to documentation changes (/configuration section)
  * Special attention to behaviour changes that are described somewhere in the
    docs
  * Add an entry to `news` about the new release. Explain it for humans. Thank
    main contributors.
  * Updaqte the `Updated tp version x.x.x` string

## Make a release candidate

* Merge all code that needs to be merged for the release. Double check on
  master:
  * It builds.
  * `gx deps dupes` is empty.
  * All the dependency tree is pinned (`gx2cluster`).
  * `ipfs-cluster-service` starts with a configuration file from the last
    release just fine.
  * Depending on what has changed in the release, it might be useful to run a
  test deployment of cluster and make sure things look fine.
  * Make sure to start a peer at least and check that there is no weird log
    messages on boot.
* Fully clean your repository workspace: there should not be anything in it
that is not part of the repository (untracked files).
* Call the `/release.sh 0.x.x-rc1` on master:
  * IPFS daemon must be started before.
  * git must be able to sign commits.
  * `gx` must be installed in the system.
  * It seds and replaces the version numbers in the code, signs and commits
    the new Release, tags the new Release with an annotated signed tag which
    includes the full changelog since last stable release, and gx-releases the
    whole thing (which again, signs the gx-release commit).
    * Triple-check all is well. If not, remove tags, reset to `origin/master
      --hard`.
    * `git push origin master --tags` NO TURNING BACK FROM THIS POINT.
  * Pin the new ipfs-cluster gx hash.
* Publish the new release to `dist.ipfs.io`:
  * Keep your cluster repository in master and don't touch anything in it.
  * ipfs daemon must be running.
  * Check out `ipfs/distributions`. Make a branch. Update the `versions` file
    and add the new RC (MUST HAVE A NEW LINE AT THE END). `make clean` ->
    `make publish`. This will take a while.
  * `ipfs object diff /ipns/dist.ipfs.io (tail -n1 versions )` should only
    show changes in cluster folders.
  * Commit and push the branch, add the `ipfs object diff output` to the PR,
    wait for travis to be green and merge.
  * Pin the new dist hash.
  * Update DNSSimple entry for `dist.ipfs.io` to the new hash.
* Deploy storage cluster with the new release:
  * `ipfs-cluster-infra/ansible` repo, update the configurations and run
    `ansible`.
  * If configurations changed, you may need to update `ansible-ipfs-cluster`
    submodule.
* Update the pinbot to the new cluster version:
  * `ipfs/pinbot-irc` and `gx update ipfs-cluster
    github.com/ipfs-cluster/ipfs-cluster`.
  * Any `client` API changes might need to fix the pinbot code.
  * Commit and push.
  * Deploy the pinbot by updated the ref commit in
    `ipfs-cluster-infra/ansible`.
* Announce the RC to the world via twitter.

## Testing

* This is the triple check that things should be working as they should.  Most
of this testing should have happened locally before making the RC.
* Storage cluster started just fine.
* Pinbot works with the new cluster and in the new pinbot version.
* Test that things that were introduced are actually doing what they should be
  doing (again).
* Test that bugfixes are actually fixed (again).
* Depending on the introduced changes, let the RC rest for a couple of days.

## Make the final release

* Set the right date in the changelog branch. Ensure all issue links are
  there.  Merge.
* Close `Release issue`.
* Set the right date in the `news` post in the website.
* If there have been changes since the RC, double check the same things on
  master as with RC.
* Fully clean your repo space as with the RC.
* Call `/release.sh 0.x.x`. Same subtasks as with the RC.
* Publish the new release to `dist.ipfs.io`. Same procedure except:
  * Need to update the `current` files to the new version. THEY NEED TO HAVE A
  NEW LINE AT THE END.
* Merge the documentation for the website.
  * Check that Jenkins actually built the website and published it.
  * Pin the new hash.
* Deploy storage cluster with the stable.
* Update the pinbots to the stable.
* Announce to the world.
