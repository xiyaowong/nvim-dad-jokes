# nvim-dad-jokes

A simple plugin that sends you some dad jokes.

## Usage

by default

```lua
require('dad-joke').setup({
  enable_interval = false,
  interval = 10 * 60 * 1000, -- (10 minutes)
  display_timeout = 5000, -- (5 seconds) the notification window's lifetime
})
```

## Commands

```viml
:DadJoke " Just get one joke
:DadJokeStart
:DadJokeStop
```

## Inspired from [vscode-dad-jokes](https://github.com/nikhiltatpati/vscode-dad-jokes)
