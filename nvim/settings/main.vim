let settingsPath = '~/.config/nvim/settings'
let expandedSettingsPath = expand(settingsPath)
let uname = system("uname -s")

"if windows path fix
let slash = '/'
if has("win32") || has("win64")
  let slash = '\'
  let settingsPath = substitute(settingsPath, '/', slash, 'g')
endif


for fpath in split(globpath(settingsPath, '*.vim'), '\n')
  if (fpath != expandedSettingsPath . slash . "main.vim") " skip main.vim (this file)

     " Skip platform specific keymaps
    if (fpath == expandedSettingsPath . slash . "vim-keymaps-mac.vim") && uname[:4] ==? "linux"
      continue " skip mac mappings for linux
    endif

    if (fpath == expandedSettingsPath . slash . "vim-keymaps-linux.vim") && uname[:4] !=? "linux"
      continue " skip linux mappings for mac
    endif

    " echo "Sourcing custom before setting: " . fpath
    exe 'source' fpath
  end
endfor

