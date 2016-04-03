" credit: Luc Hermitte
function! helpers#register_command(event, cmd, group)
  let group = a:group.'_once'
  let s:{group} = 0
  exe 'augroup '.group
  au!
  exe 'au ' .a:event. ' ' .expand('%:p').
    \ ' call helpers#registered_once('.string(a:cmd).','.string(group).')'
  augroup END
endfunction

" credit: Luc Hermitte
function! helpers#registered_once(cmd, group)
  " We can't delete the current  autocommand => increment a counter
  if !exists('s:'.a:group) || s:{a:group} == 0
    let s:{a:group} = 1
    exe a:cmd
  endif
endfunction
