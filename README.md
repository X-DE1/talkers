# Talkers

Adds an API to add talking NPCs with [ollama](https://ollama.com) and [Mobs Redo API](https://content.luanti.org/packages/TenPlus1/mobs/).

Read talkers.lua to see how the API works.
<br>
talkers.register_talker(name, register_mob, characters, tool, url, ai, wait)

If you add this mod in secure.trusted_mods, secure.http_mods in advanced settings, have wandering_traders mod and qwen3:0.6b in http://localhost:11434/api/chat you can test the result of the api.

## Installation

### ContentDB

* Content > Browse Online Content
* Search for "Talkers"
* Click Install

### Manually

- Unzip the archive, rename the folder to `talkers` and
place it in `.../minetest/mods/`

- GNU/Linux: If you use a system-wide installation place it in `~/.minetest/mods/`.

The Luanti engine can be found at [GitHub](https://github.com/minetest/minetest).

For further information or help, see: [Installing Mods](https://wiki.luanti.org/Installing_Mods).

## License

See `LICENSE.txt`
