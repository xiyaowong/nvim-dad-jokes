if exists('g:loaded_dad_joke') | finish | endif

let g:loaded_dad_joke = 1

augroup DadJoke
  autocmd!
  command! DadJoke      lua require('dad-joke').fetch()
  command! DadJokeStart lua require('dad-joke').start()
  command! DadJokeStop  lua require('dad-joke').stop()
augroup END
