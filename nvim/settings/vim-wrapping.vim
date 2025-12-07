" " http://vimcasts.org/episodes/soft-wrapping-text/
function! SetupWrapping()
  setlocal wrap linebreak nolist
  setlocal showbreak=…
endfunction

augroup AutoWrapFiles
    autocmd!
    autocmd FileType {tex,text} call SetupWrapping()
augroup END

command! -nargs=* Wrap :call SetupWrapping()<CR>

vmap <D-j> gj
vmap <D-k> gk
vmap <D-$> g$
vmap <D-^> g^
vmap <D-0> g^
nmap <D-j> gj
nmap <D-k> gk
nmap <D-$> g$
nmap <D-^> g^
nmap <D-0> g^

