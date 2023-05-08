new-alias ssh $env:cmder_root\vendor\git-for-windows\usr\bin\ssh.exe -erroraction silentlycontinue

function cmderr {
  cd $ENV:CMDER_ROOT
}

function va {
  vi "$ENV:CMDER_ROOT\config\user_aliases.ps1"
}

function gs {
  git status
}

function gi(){
  vi .gitignore
}

function ga($git_args) {
  if ([string]::IsNullorEmpty($git_args)) {
    $git_args = "."
  } else {
    $git_args = $args -join ' '
  }

  git add $git_args
}

function gc($git_args) {
  $git_args = $args -join ' '

  git commit $git_args
}

new-alias sublime_text '$env:cmder_root\vendor\sublime_text_3\sublime_text' -erroraction silentlycontinue
new-alias sublime_text '"$env:cmder_root\vendor\sublime_text_3\sublime_text"' -erroraction silentlycontinue
new-alias atom '"$env:cmder_root\vendor\atom\Atom\atom"' -erroraction silentlycontinue
new-alias apm '"$env:cmder_root\vendor\atom\Atom\resources\app\apm\bin\apm"' -erroraction silentlycontinue
