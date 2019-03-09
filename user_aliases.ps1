new-alias ssh $env:cmder_root\vendor\git-for-windows\usr\bin\ssh.exe -erroraction silentlycontinue

function va {
  vi "$ENV:CMDER_ROOT\config\user-aliases.ps1"
}

function gs {
  git status
}

function ga($git_args) {
  if ([string]::IsNullorEmpty($git_args)) {
    $git_args = "."
  } else {
    $git_args = $args -join ' '
  }

  git add $git_args
}

new-alias sublime_text '$env:cmder_root\vendor\sublime_text_3\sublime_text' -erroraction silentlycontinue

