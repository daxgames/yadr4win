;= @echo off
;= rem Call DOSKEY and use this file as the macrofile
;= %SystemRoot%\system32\doskey /listsize=1000 /macrofile=%0%
;= rem In batch mode, jump to the end of the file
;= goto:eof
;= Add aliases below here
e.=explorer .
gl=git log --oneline --all --graph --decorate  $*
ls=ls --show-control-chars -F --color $*
pwd=cd
clear=cls
unalias=alias /d $1
vi=vim $*
cmderr=cd /d "%CMDER_ROOT%"
ga=git add -A $*
gam=git amend --reset-author $*
gap=git add --patch $*
gau=git add --update $*
gb=git branch $*
gba=git branch -a $*
gbd=git branch -d $*
gbib=git bisect bad $*
gbig=git bisect good $*
gbm=git branch -m $*
gbr=git recent-branches $*
gbs=git show-branch $*
gbv=git branch -v $*
gbx=git branch -D $*
gc=git commit $*
gca=git commit --amend --no-edit $*
gcar=git commit --amend --reuse-message HEAD $*
gcln=git clean $*
gclndf=git clean -df $*
gclndfx=git clean -dfx $*
gclnf=git clean -f $*
gclnn=git clean -n $*
gcm=git commit -m $*
gco=git checkout $*
gcoo=git checkout --ours -- $*
gcop=git checkout --patch $*
gcot=git checkout --theirs -- $*
gcp=git cherry-pick $*
gcpnc=git cherry-pick --no-commit $*
gcre=git revert $*
gcrsh=git reset "HEAD^" $*
gcrsp=git reset --patch $*
gcrsx=git reset --hard $*
gcs=git show $*
gcv=git commit --verbose $*
gcva=git commit --verbose --amend $*
gd=git diff $*
gdc=git diff --cached -w $*
gdi=git status --porcelain --short --ignored $B sed -n "s/^!! //p" $*
gdk=git ls-files --killed $*
gdm=git ls-files --modified $*
gdu=git ls-files --other --exclude-standard $*
gdx=git ls-files --deleted $*
gf=git fetch $*
gfc=git clone $*
gfch=git fetch $*
gfm=git pull $*
gfr=git pull --rebase $*
gg=git grep $*
ggfm=git grep --files-with-matches $*
ggfmv=git grep --files-without-matches $*
ggi=git grep --ignore-case $*
ggrc=git rebase --continue $*
ggw=git grep --word-regexp $*
gi=vim .gitignore $*
gid=git diff --no-ext-diff --cached $*
gidw=git diff --no-ext-diff --cached --word-diff $*
github=cd ^%userprofile^%\repos\github $*
gitlab=cd ^%userprofile^%\repos\gitlab $*
gl=git log --graph --date=short $*
glc=git shortlog --summary --numbered $*
glg=git log --graph --date=short --oneline --decorate $*
gm=git merge $*
gma=git merge --abort $*
gmnc=git merge --no-commit $*
gmnff=git merge --no-ff $*
gms=git merge --squash $*
gmt=git mergetool $*
gnb=git checkout -b $*
gnb=git nb $*
gp=git push $*
gpa=git push --all $*
gpat=git push --all $T$T git push --tags $*
gpf=git push --force $*
gpl=git pull $*
gplr=git pull --rebase $*
gps=git push $*
gpsa=git push --all $*
gpsf=git push --force $*
gpst=git push --tags $*
gr=git remote $*
gra=git remote add $*
grb=git rebase $*
grba=git rebase --abort $*
grbc=git rebase --continue $*
grbi=git rebase --interactive $*
grn=git remote rename $*
grp=git remote prune $*
grrm=git remote rm $*
grs=git reset $*
grsh=git remote show  $*
grsu=git remote set-url $*
grsh=git reset --hard $*
grsp=git reset --patch $*
gru=git remote update $*
grv=git remote -v $*
gs=git status $*
gsa=git stash apply $*
gsd=git stash drop $*
gsh=git show $*
gshd=git stash show --patch --stat $*
gsl=git stash list $*
gsm=git submodule $*
gsma=git submodule add $*
gsmf=git submodule foreach $*
gsmfpl=git submodule foreach git pull origin master $*
gsmi=git submodule init $*
gsms=git submodule status $*
gsmsy=git submodule sync $*
gsmu=git submodule update $*
gsmuir=git submodule update --init --recursive $*
gsp=git stash pop $*
gss=git stash save --include-untracked $*
gssp=git stash save --patch --no-keep-index $*
gt=git tag -n $*
gunc=git uncommit $*
guns=git unstage $*
ll=ls -la --color $*
ls=ls --color $*
repos=cd ^%userprofile^%\repos\$1 $*
vimdiff=vim -d $*
np=notepad $*
g=git $*
vi=vim $*
cmderr=cd %cmder_root%
home=cd /d %USERPROFILE%
~=cd /d %USERPROFILE%
va=vim "%CMDER_ROOT%\config\user_aliases.cmd"
nvim="%CMDER_ROOT%\bin\neovim\bin\nvim.exe" $*
..=cd ..
vi=vim $*
sublime_text="%CMDER_ROOT%\vendor\sublime_text_3\sublime_text"
atom="%CMDER_ROOT%\vendor\atom\Atom\atom $*"
apm="%CMDER_ROOT%\vendor\atom\Atom\resources\app\apm\bin\apm $*"
history3=cat -n %CMDER_ROOT%\config\.history
history4=cat -n "%CMDER_ROOT%\config\.history"
history5=cat -n "C:\Users\user\cmder dev\config\.history"
history6=cat -n C:\Users\user\cmder dev\config\.history
history2=cat -n %CMDER_ROOT%\config\.history
myupstream=git remote -v $b grep upstream $b head -n 1 $b cut -f 2 $b cut -d ' ' -f 1 $g %temp%\repo.tmp $t unix2dos %temp%\repo.tmp 2$lnull $t sleep 1 $t set /p x=$l%temp%\repo.tmp $t start /b %x%
myrepo=git remote -v $b grep origin $b head -n 1 $b cut -f 2 $b cut -d ' ' -f 1 $g %temp%\repo.tmp $t unix2dos %temp%\repo.tmp 2$lnull $t sleep 1 $t set /p x=$l%temp%\repo.tmp $t start /b %x%
subl="%CMDER_ROOT%\bin\sublime_text\sublime_text.exe" $*
sublv="%CMDER_ROOT%\bin\sublime_text\sublime_text.exe" $* -new_console:s50H
subls="%CMDER_ROOT%\bin\sublime_text\sublime_text.exe" $* -new_console:s50V
pip=python -m pip $*
