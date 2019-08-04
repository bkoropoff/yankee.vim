nnoremap <silent> <Plug>(YankeePasteAfter) :<C-u>call yankee#paste('p', 0)<cr>
nnoremap <silent> <Plug>(YankeePasteBefore) :<C-u>call yankee#paste('P', 0)<cr>
xnoremap <silent> <Plug>(YankeePasteAfter) :<C-u>call yankee#paste('p', 1)<cr>
xnoremap <silent> <Plug>(YankeePasteBefore) :<C-u>call yankee#paste('P', 1)<cr>

if get(g:, 'yankee_disable', 0)
    call yankee#ring#detach()
    for m in ['n', 'x']
        for k in ['p', 'P']
            if maparg(k, m) =~ '^<Plug>(YankeePaste'
                exec m.'unmap' k
            endif
        endfor
    endfor
    finish
endif

nmap p <Plug>(YankeePasteAfter)
nmap P <Plug>(YankeePasteBefore)
xmap p <Plug>(YankeePasteAfter)
xmap P <Plug>(YankeePasteBefore)

call yankee#ring#attach()
