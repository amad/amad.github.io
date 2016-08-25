---
title: Git friendly Terminal
description: Sharing my terminal aliases
keywords: git, bash aliases, bash, terminal, git aliases
date: 2016-06-09
permalink: "/blog/git-friendly-terminal.html"
---

If you are a software developer, you recognize that the majority of executed commands in your terminal are git commands.

A quick way to find which commands you are using the most is checking your history:

```bash
$ history | awk '{print $1}' | sort | uniq -c | sort -bg
```

Even for me, as a heavy terminal user, `git` is still on the top with a big difference and I know that it is the same for the largest number of developers.

When you use git on the command-line, It's incredibly useful to use aliases and that is what most of the developers do eventually.

I tend to keep my aliases intuitive, instead of making everything shorter by using abbreviations. Well, there is no problem in using short abbreviations for GIT commands infact I also have some, except that your co-worker has no idea what you are doing by looking at your screen. As someone that does a lot of pair-programming that is important for me.

Here is some examples of short aliases which many of you are already familiar.

```bash
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gap='git apply'
```

And now compare it to what I call intuitive aliases.

```bash
alias master='git checkout master'
alias dev='git checkout dev'
alias back='git checkout -'
alias new='git checkout -b'
alias checkout='git checkout'
alias branch='git branch'
alias branches='git branch -a'
alias rmbranch='git branch -D'
```

So I say `checkout` instead of `git checkout`, I just say `master` to checkout master branch, and I use `back` to checkout the previous branch.

I don't afraid to use these keywords (like `back`), because most of my terminal usage is `git` anyways so it makes sense to give it more superiority. The good part is that I still only use two/three keystrokes because my shells autocomplete does most of the job for me while everything reads better on my screen.

It gets more interesting with more examples,

```bash
alias push='git push origin HEAD'
alias forcepush='git push --force-with-lease origin HEAD'

alias commit='git commit'
alias gc='git commit'
alias wip='git commit -m "WIP"'

alias unstage='git reset HEAD'
alias unstageall='git reset HEAD .'

alias undo='git reset --soft HEAD^'
alias undopush='git push -f origin HEAD^:master'
```

I can say `push` to push my changes to the origin which is where I push 99% of the time, and `forcepush` will do the same with `--force-with-lease` option added.

I have `wip` to create a dirty work-in-progress commit. I can unsatge everything by just saying `unstage`.

`undo` would revert my last commit and `undopush` will revert the last thing I pushed to the origin if needed.

And yet my pair can always follow me easily as commands are representing actions. Let's explore some other aliases that I'm using.

```bash
alias stash='git stash -k -u'
alias stashall='git stash --include-untracked'
alias pop='git stash pop'
```

Nothing can tell that I want to stash better than `stash`. while I also have `-u` added to make sure I stash untracked files as well.

```bash
alias fixup='git commit --fixup'
alias rebaseme='git rebase master --autostash'
alias rebase='git rebase --autostash'
alias autorebase='git rebase -i --autosquash --autostash'
```

I can `fixup a change to a commit message`, and then `autorebase` will rebase and squash everything for me. If I'm just about to rebase with master, I can say `rebaseme`. I also have use `pullme` to update and rebase my working branch with upstream/master.

Here you can see more examples:

```bash
alias merge='git merge'
alias allmerged='git branch --merged -r | grep -v "\*"'
alias notmerged='git branch --no-merged'
alias show-ref='git show-ref'
alias show='git show'
alias news='git log ..master'
alias mergenoff='git merge --no-ff'
alias revert='git revert'
alias addremote='git remote add'
alias remotes='git remote -v'
alias log='git log -p --decorate'
alias clone='git clone'
alias fetch='git fetch -p'
alias fetchall='git fetch -all'
alias pull='git pull --rebase --prune --verbose --no-ff --no-commit --no-stat --autostash'
alias pullme='git fetch -p upstream; git pull --rebase --prune --verbose --no-ff --no-commit --no-stat --autostash upstream master'
alias newfiles='git whatchanged --diff-filter=A'
alias standup='git --no-pager log --all --no-merges --oneline --date="relative" --since="yesterday"'
alias mystandup='standup --author=$(git config user.name)'
```

I have more aliases, but I just wanted to give you the idea. However it is not only about aliases, your terminal and shell environment can also help you a lot.

## Autocomplete

I'm using fish-shell which has built-in `git` autocomplete enabled by default. It also gives me extra power with autocomplete on my history.

If you use a different shell environment, just source the following files in your shell profile to make your life a lot easier.

```bash
source /usr/local/git/contrib/completion/git-completion.bash
source /usr/local/git/contrib/completion/git-prompt.sh
```

If you couldn't find these paths. take a look [here](https://github.com/git/git/tree/master/contrib/completion).

Also, for those that are using `zsh`, verify that git plugin is enabled, then take a look [here](https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/git/git.plugin.zsh), and [here](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins), to see what else you have got by default.
