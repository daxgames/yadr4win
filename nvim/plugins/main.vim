if (!has('nvim'))
  " Make traditional vim aware of this folder so Plug can install itself in
  " there as well
  let &rtp = &rtp . ',  ~/.local/share/nvim/site/'
endif

source ~/.config/nvim/settings/before/000-run_first.vim

let g:session_autosave = 'no'
" if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
"   silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"   autocmd VimEnter * PlugInstall --sync
" endif

call plug#begin('~/.local/share/nvim/site/plugged')

let pluginPath = '~/.config/nvim/plugins'

"if windows path fix
let slash = '/'
if has("win32") || has("win64")
  let slash = '\'
  let pluginPath = substitute(pluginPath, '/', slash, 'g')
endif

for fpath in split(globpath(pluginPath, '*.vim'), '\n')
  if (fpath != expand(pluginPath) . slash . "main.vim") " skip main.vim (this file)
    " echo "Sourcing plugin file: " . fpath
    exe 'source' fpath
  endif
endfor

call plug#end()
