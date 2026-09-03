 # Git Homework Submission

This folder contains the command record for the Git homework tasks.

## Task 1: `git commit -a -m` versus `git commit -m`

`git commit -a -m "message"` stages and commits modifications and deletions to
files Git already tracks. It does not include new, untracked files.

`git commit -m "message"` commits only what is already staged, whether that is
a new file, a modification, or a deletion.

The commands and observed output are recorded below after the exercise is run.

First, I modified this tracked README and created `task1-untracked.txt`, then
ran:

```bash
git commit -a -m "git homework: test commit all"
```

The commit included the README modification but left the new file untracked.

Observed output:

```text
[main a6580ab] git homework: test commit all
 2 files changed, 11 insertions(+), 1 deletion(-)
?? assignments/git-github/task1-untracked.txt
```

To commit the new file, I ran:

```bash
git add assignments/git-github/task1-untracked.txt
git commit -m "git homework: add untracked file"
```

## Task 2: Cherry-pick

The exercise creates several commits on `main`, creates a separate branch with
multiple commits, then cherry-picks one selected commit back into `main`.

The final log and verification output are recorded below.

On `git-homework-cherry-pick`, `git log --oneline --decorate -4` identified
the second branch commit as the selected commit:

```text
<selected-commit> (HEAD -> git-homework-cherry-pick) git homework: selected cherry-pick change
48cf6f9 git homework: add branch-only change
b81c20e (main) git homework: add untracked file
```

From `main`, I ran:

```bash
git cherry-pick <selected-commit>
```

This brought `cherry-pick-selected.txt` into `main`; the branch-only file was
not brought over.
