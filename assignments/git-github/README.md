 # Git Homework Submission

This folder contains the command record for the Git homework tasks.

## Task 1: `git commit -a -m` versus `git commit -m`

`git commit -a -m "message"` stages and commits modifications and deletions to
files Git already tracks. It does not include new, untracked files.

`git commit -m "message"` commits only what is already staged, whether that is
a new file, a modification, or a deletion.

The commands and observed output are recorded below after the exercise is run.

## Task 2: Cherry-pick

The exercise creates several commits on `main`, creates a separate branch with
multiple commits, then cherry-picks one selected commit back into `main`.

The final log and verification output are recorded below.
