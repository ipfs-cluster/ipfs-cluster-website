+++
title = "Guidelines for contributing"
+++


# Guidelines for contributing

## General guidelines

IPFS Cluster adopts the existing guidelines in the IPFS community:

* The [go-ipfs contributing guidelines](https://github.com/ipfs/go-ipfs/blob/master/contribute.md), which builds upon:
* The [IPFS Community Code of Conduct](https://github.com/ipfs/community/blob/master/code-of-conduct.md)
* The [IPFS community contributing notes](https://github.com/ipfs/community/blob/master/contributing.md)
* The [Go contribution guidelines](https://github.com/ipfs/community/blob/master/go-code-guidelines.md)

## Getting oriented

To check what's going on in the project, check:

- the [Changelog](https://github.com/ipfs/ipfs-cluster/blob/master/CHANGELOG.md)
- the [News](/news)
- the [Waffle board](https://waffle.io/ipfs/ipfs-cluster)
- the [Roadmap](/roadmap)
- the [upcoming release issues](https://github.com/ipfs/ipfs-cluster/issues?q=label%3Arelease)

If you are looking for things to start with, [filter for issues with `easy` and `ready` labels](https://github.com/ipfs/ipfs-cluster/issues?q=is%3Aopen+is%3Aissue+label%3Adifficulty%3Aeasy+label%3Aready).

In general, [anything marked with `help wanted`](https://github.com/ipfs/ipfs-cluster/issues?q=is%3Aopen+is%3Aissue+label%3Aready+label%3A%22help+wanted%22) is ready to be taken on by external contributors.

Please [let us know](/documentation#support) when you are going to work on something, or more clarifications are needed, so we can help you out!

## Code contribution guidelines

In practice, these are our soft standards:

* IPFS Cluster uses the MIT license.
* All contributions are via Pull Request, which needs a Code Review approval from one of the project collaborators.
* Tests must pass
* Code coverage must be stable or increase
* We prefer meaningul branch names: `feat/`, `fix/`...
* We prefer commit messages which reference an issue `fix #999: ...`
* The commit message should end with the following trailers :

  ```
  License: MIT
  Signed-off-by: User Name <email@address>
  ```

  where "User Name" is the author's real (legal) name and
  email@address is one of the author's valid email addresses.

  These trailers mean that the author agrees with the 
  [developer certificate of origin](/developer-certificate-of-origin.txt)
  and with licensing the work under the [MIT license](https://github.com/ipfs/ipfs-cluster/blob/master/LICENSE).

  To help you automatically add these trailers, you can run the
  [setup_commit_msg_hook.sh](https://raw.githubusercontent.com/ipfs/community/master/dev/hooks/setup_commit_msg_hook.sh)
  script which will setup a Git commit-msg hook that will add the above
  trailers to all the commit messages you write.


These are just guidelines. We are friendly people and are happy to help :)
