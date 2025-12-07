" Make it beautiful - colors and fonts

" colorscheme base16-lfilho
" let base16colorspace=256
" let g:hybrid_custom_term_colors = 1
" let g:hybrid_reduced_contrast = 1

if has("termguicolors")
  set termguicolors
endif

set background=dark
if has("gui_running")
  set lines=60
  set columns=190

  " Show tab number (useful for Cmd-1, Cmd-2.. mapping)
  " For some reason this doesn't work as a regular set command,
  " (the numbers don't show up) so I made it a VimEnter event
  autocmd VimEnter * set guitablabel=%N:\ %t\ %M

  if has("gui_gtk2")
    "tell the term has 256 colors
    set t_Co=256
    set guifont=Fira\ Code\ h12
  else
    let g:CSApprox_loaded = 1

    " For people using a terminal that is not Solarized
    if exists("g:yadr_using_unsolarized_terminal")
      let g:solarized_termcolors=256
      let g:solarized_termtrans=1
    end

    set guifont=Fira\ Code:h12
  end
endif

colorscheme onehalfdark

" Highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
" Hide ~ for blank lines
hi NonText guifg=bg
set cursorline

" Don't try to highlight lines longer than 800 characters.
set synmaxcol=800

" Resize splits when the window is resized
au VimResized * :wincmd =
