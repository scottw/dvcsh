# dvcsh - A distributed version control system in Bourne shell

This repository holds the source for the elemental parts needed for a
simple VCS written in Bourne shell. This is an academic exercise and
should not be used for actual version control of anything critical.

## Motivation

The reason for this is purely heuristic: how might one approach
building a DVCS like `git`? Once you can understand this small bit of
Bourne shell, you can also understand many of the underpinnings and
architectural decisions that went into `git` and thereby gain a
sufficiently robust mental model for understanding `git` better.

This repo will also hold additional `git` training and a presentation
that accompany this shell file.

## Suggested Usage

1. Read the source
2. Play with it
3. Enjoy enlightenment

## Pedantic Usage

Source the file:

    $ source dvc.sh

This will import the shell function definitions into your current
shell session.

Create an empty directory and initialize it as a repo:

    $ mkdir my-repo
    $ cd my-repo
    $ init .

View the empty repo:

    $ find .dvcsh -type f -print

Create a new file and add it into the repo:

    $ echo "some file" > some-file.txt
    $ add some-file.txt

View the new object and index in the repo:

    $ find .dvcsh -type f -print
    $ cat .dvcsh/index

Commit the changes:

    $ commit "first commit"

View the commit object and other artifacts:

    $ find .dvcsh -type f -print | xargs head

## Future Work

It would be fairly easy to make this even more git-like by adding tree
objects. The `diff`, `checkout`, and `tag` commands are also
low-hanging fruit at this point. With this one little file, we could
be self-hosting and on our way to a lovely little DVCS of our
own... if this weren't a purely academic exercise. Enjoy!

## Warnings

This shell file exports a handful of symbols into your shell:

* _hash_obj
* init
* add
* commit
* log

If you have executables or other shell functions defined, they will be
clobbered until your next shell session.
