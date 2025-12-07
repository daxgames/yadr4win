" Change leader to a comma because the backslash is too far away
" That means all \x commands turn into ,x
" The mapleader has to be set before loading all the plugins.
let mapleader=","

" This line prevents polyglot from loading markdown packages and needs to be
" defined before everything else
let g:polyglot_disabled = ['md', 'markdown']

