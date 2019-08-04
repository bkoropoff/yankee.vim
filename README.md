# Fancy-ish yank ring for VIM

This overrides the `p`/`P` mappings in normal and visual mode to paste from a
ring of previously yanked/deleted text similar to the kill ring in Emacs.
After a paste, you will be left in a "minimode" with help text in the cmdline
area.  Pressing `p` again will cycle through the ring entries (`P` cycle
backwards).  You can restrict the cycling to entries matching a pattern by
pressing `/`.  Any other key will transparently leave the minimode and perform
that keys normal action.

The following should work as expected:

- Pasting with a count
- Pasting from a non-default register (does not start the ring)
- Pasting into a terminal buffer
- `clipboard=unnamed` and `clipboard=unnamedplus`

## Installation

Use your favorite plugin manager to install this plugin and its dependency,
`bkoropoff/minimode.vim`.  E.g. with vim-plug:

```vim
Plug 'bkoropoff/minimode.vim'
Plug 'bkoropoff/yankee.vim'
```

## Configuration

To configure the maximum size of the yank ring (default 50):

```vim
let g:yankee_ring_size = 100
```

To prevent yankee from automatically overriding mappings and starting the yank
ring:

```vim
let g:yankee_disable = 1
```

If you do this, you'll need to create your own mappings and start it manually
at an appropriate time, e.g.:

```vim
nmap <Leader>p <Plug>(YankeePasteAfter)
nmap <Leader>P <Plug>(YankeePasteBefore)
xmap <Leader>p <Plug>(YankeePasteAfter)
xmap <Leader>P <Plug>(YankeePasteBefore)

call yankee#ring#attach()
```

You can use `yankee#ring#detach()` to stop the yank ring.

## Clear

To clear the yank ring, call `yankee#ring#clear()`.
