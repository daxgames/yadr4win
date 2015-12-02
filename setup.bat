if exist "%USERPROFILE%\.vimrc" (
  echo Backing up "%USERPROFILE%\.vimrc" to ".vimrc.yadr4win
  ren "%USERPROFILE%\.vimrc" .vimrc.yad4win"
)
  
mklink /h "%USERPROFILE%\.vimrc" "%USERPROFILE%\.yadr4win\vimrc"

if exist "%USERPROFILE%\.gitconfig" (
  echo Backing up "%USERPROFILE%\.gitconfig" to ".gitconfig.yadr4win
  ren "%USERPROFILE%\.gitconfig" .gitconfig.yad4win"
)
  
mklink /h "%USERPROFILE%\.gitconfig" "%USERPROFILE%\.yadr4win\git\gitconfig"

if exist "%USERPROFILE%\.tmux.conf" (
  echo Backing up "%USERPROFILE%\.tmux.conf" to ".tmux.conf.yadr4win
  ren "%USERPROFILE%\.tmux.conf" .tmux.conf.yad4win"
)
  
mklink /h "%USERPROFILE%\.tmux.conf" "%USERPROFILE%\.yadr4win\tmux\tmux.conf"

if exist "%USERPROFILE%\.vim" (
  echo Backing up "%USERPROFILE%\.vim" to ".vim.yadr4win
  rendir "%USERPROFILE%\.vim" .vim.yad4win"
)
  
mklink /d "%USERPROFILE%\.vim" "%USERPROFILE%\.yadr4win\vim"

