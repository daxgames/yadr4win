" This is where you can configure anything that needs to be loaded or
" configured before the rest of the configuration and/or before some plugin
" get loaded. For example, changing the leader key to your desire.

" Just put a new .vim file in this folder and it will get sourced here. Those
" files will be ignored by git so you don't need to fork the repo just for
" these kind of customizations.

let customSettingsPath = '~/.config/nvim/settings/before'

"if windows path fix
let slash = '/'
if has("win32") || has("win64")
  let slash = '\'
  let customSettingsPath = substitute(customSettingsPath, '/', slash, 'g')
endif

for fpath in split(globpath(customSettingsPath, '*.vim'), '\n')
  if (fpath != expand(customSettingsPath) . slash . "main.vim") " skip main.vim (this file)
    " echo "Sourcing custom before setting: " . fpath
    exe 'source' fpath
  endif
endfor
