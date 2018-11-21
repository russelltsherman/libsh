# libsh

a collection of common shell functions

## usage

include into your git repo as subtree

```sh
git remote add libsh https://github.com/russelltsherman/libsh
git subtree add --squash --prefix=libsh/ libsh master
```

pull in upstream changes

```sh
git subtree pull --squash --prefix=libsh/ libsh master
```

include into your shell script

```sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/libsh/all.sh"
```
