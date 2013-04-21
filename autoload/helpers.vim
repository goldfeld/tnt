" credit: Luc Hermitte
" http://code.google.com/p/lh-vim/source/search?q=register_for&origq=register_for&btnG=Search+Trunk
function! helpers#registerCommand(event, cmd, group)
  let group = a:group.'_once'
  let s:{group} = 0
  exe 'augroup '.group
  au!
  exe 'au '.a:event.' '.expand('%:p').' call helpers#registeredOnce('.string(a:cmd).','.string(group).')'
  augroup END
endfunction
function! helpers#registeredOnce(cmd, group)
  " We can't delete the current  autocommand => increment a counter
  if !exists('s:'.a:group) || s:{a:group} == 0
    let s:{a:group} = 1
    exe a:cmd
  endif
endfunction

