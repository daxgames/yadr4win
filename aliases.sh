alias g='git'
alias ga='git add -A'
alias gam='git amend --reset-author'
alias gau='git add --update'
alias gb='git branch'
alias gba='git branch -a'
alias gbc='git checkout -b'
alias gbd='git branch -D -w'
alias gbib='git bisect bad'
alias gbig='git bisect good'
alias gbm='git branch -m'
alias gbr='git recent-branches'
alias gbs='git show-branch'
alias gbv='git branch -v'
alias gbx='git branch -D'
alias gc='git commit'
alias gca='git commit --amend --no-edit'
alias gcf='git commit --amend --reuse-message HEAD'
alias gcln='git clean'
alias gclndf='git clean -df'
alias gclndfx='git clean -dfx'
alias gclnf='git clean -f'
alias gclnn='git clean -n'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcoo='git checkout --ours --'
alias gcop='git checkout --patch'
alias gcot='git checkout --theirs --'
alias gcp='git cherry-pick'
alias gcpnc='git cherry-pick --no-commit'
alias gcre='git revert'
alias gcrsh='git reset "HEAD^"'
alias gcrsp='git reset --patch'
alias gcrsx='git reset --hard'
alias gcs='git show'
alias gcv='git commit --verbose'
alias gcva='git commit --verbose --amend'
alias gd='git diff'
alias gdc='git diff --cached -w'
alias gdi='git status --porcelain --short --ignored | sed -n "s/^!! //p"'
alias gdk='git ls-files --killed'
alias gdm='git ls-files --modified'
alias gdu='git ls-files --other --exclude-standard'
alias gdx='git ls-files --deleted'
alias gf='git fetch'
alias gfc='git clone'
alias gfch='git fetch'
alias gfm='git pull'
alias gfr='git pull --rebase'
alias gg='git grep'
alias ggf='git grep --files-with-matches'
alias ggfv='git grep --files-without-matches'
alias ggi='git grep --ignore-case'
alias ggv='git grep --invert-match'
alias ggw='git grep --word-regexp'
alias gi='vim .gitignore'
alias gid='git diff --no-ext-diff --cached'
alias gidw='git diff --no-ext-diff --cached --word-diff'
alias github='cd $HOME/repos/github'
alias gitlab='cd $HOME/repos/gitlab'
alias gl='git log --graph --date=short'
alias glc='git shortlog --summary --numbered'
alias glg='git log --graph --date=short'
alias gm='git merge'
alias gma='git merge --abort'
alias gmC='git merge --no-commit'
alias gmF='git merge --no-ff'
alias gms='git merge --squash'
alias gmt='git mergetool'
alias gnb='git checkout -b'
alias gnb='git nb'
alias gp='git push'
alias gpat='git push --all && git push --tags'
alias gpa='git push --all'
alias gpf='git push --force'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gps='git push'
alias gpsa='git push --all'
alias gpsaf='git push --all --force'
alias gpt='git push --tags'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grc='git rebase --abort'
alias grc='git rebase --continue'
alias gri='git rebase --interactive'
alias gRm='git remote rename'
alias gRp='git remote prune'
alias grr='git remote rm'
alias grs='git reset'
alias grsh='git remote show'
alias grsu='git remote set-url'
alias grsh='git reset --hard'
alias grsp='git reset --patch'
alias gru='git remote update'
alias grv='git remote -v'
alias gs='git status'
alias gsa='git stash apply'
alias gsd='git stash drop'
alias gsh='git show'
alias gshd='git stash show --patch --stat'
alias gsl='git stash list'
alias gsm='git submodule'
alias gsma='git submodule add'
alias gsmf='git submodule foreach'
alias gsmfpl='git submodule foreach git pull origin master'
alias gsmi='git submodule init'
alias gsms='git submodule status'
alias gsmsy='git submodule sync'
alias gsmu='git submodule update'
alias gsmuir='git submodule update --init --recursive'
alias gsp='git stash pop'
alias gss='git stash save --include-untracked'
alias gssp='git stash save --patch --no-keep-index'
alias gt='git tag -n'
alias gunc='git uncommit'
alias guns='git unstage'
alias ll='ls -la --color'
alias ls='ls --color'
alias vimdiff='vim -d'
