# gldnrmz-dumpsters

Dumpster diving and trash selling. Original dumpster script by [zf-labo](https://github.com/zf-labo/zf-dumpster-qb).

Works on Qbox, QBCore and ESX with any target, inventory, menu, notify, progress bar and dispatch supported by [community_bridge](https://github.com/TheOrderFivem/community_bridge).

## ✨ Features
- Search anything that looks like it contains trash (`Config.Props`)
- Tier-based loot, with a chance of getting hurt or bleeding
- Sell trash to homeless peds; they may steal your food and drugs instead
- Optional storage inside dumpsters (code snippets from [Jakers](https://jakers.tebex.io/package/4923802))
- Optional police alert and minigame

## 📦 Requirements
- [community_bridge](https://github.com/TheOrderFivem/community_bridge) **0.13.6 or newer** ([Qbox](https://github.com/Qbox-project/qbx_core), [QBCore](https://github.com/qbcore-framework/qb-core) or [ESX](https://github.com/esx-framework/esx_core))
- Optional minigames (`Config.Minigame`): `qb-lock`, `memorygame` or `ps-ui` (off by default)

## ⚡ Installation
1. Start `community_bridge` before this resource, then add `ensure gldnrmz-dumpsters` to `server.cfg`.
2. Add the items below to your inventory's item list (QBCore format shown; use the same names for ox_inventory or ESX), and copy the images from `images/` into your inventory's image folder.
3. Adjust `config.lua` (searchable props, loot tiers, sell prices, homeless ped locations).

```lua
['cd'] 				             = {['name'] = 'cd', 			  	  	        ['label'] = 'Compact Disk', 		    ['weight'] = 50, 		['type'] = 'item', 		['image'] = 'cd.png', 		        ['unique'] = false, 	['useable'] = false,  	['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'Relic of the 90s'},
['newspaper'] 			 	     = {['name'] = 'newspaper', 			  		['label'] = 'Old Newspaper', 		    ['weight'] = 50, 		['type'] = 'item', 		['image'] = 'newspaper.png', 		['unique'] = false,		['useable'] = false,  	['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'Last weeks newspaper'},
['wrapper'] 			 	     = {['name'] = 'wrapper', 					    ['label'] = 'Used Food Wrapper', 		['weight'] = 50, 		['type'] = 'item', 		['image'] = 'wrapper.png', 		    ['unique'] = false,	    ['useable'] = false,  	['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'Up-N-Atom Burger wrapper'},
['rat'] 			   	         = {['name'] = 'rat', 					        ['label'] = 'Dead Rat', 		        ['weight'] = 50, 	    ['type'] = 'item', 		['image'] = 'rat.png', 		        ['unique'] = false,	    ['useable'] = false, 	['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'Stinky dead rat'},
['roach'] 			 	         = {['name'] = 'roach', 					    ['label'] = 'Cockroach', 		        ['weight'] = 50, 		['type'] = 'item', 		['image'] = 'roach.png', 		    ['unique'] = false, 	['useable'] = false, 	['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'A live cockroach'},
['gum'] 				 	     = {['name'] = 'gum', 			  	  		    ['label'] = 'Empty Pack of Gum', 		['weight'] = 50, 		['type'] = 'item', 		['image'] = 'gum.png', 			    ['unique'] = false, 	['useable'] = false,  	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Its empty'},
['napkin'] 				         = {['name'] = 'napkin', 			  	        ['label'] = 'Greasy Napkin', 			['weight'] = 50, 		['type'] = 'item', 		['image'] = 'napkin.png', 	        ['unique'] = false, 	['useable'] = false,  	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Napkin with leftover ketchop'},
['safetypin'] 				     = {['name'] = 'safetypin', 			  	  	['label'] = 'Broken Safety Pin', 	    ['weight'] = 50, 		['type'] = 'item', 		['image'] = 'safetypin.png', 		['unique'] = false, 	['useable'] = false, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Broken Safety Pin'},
['scrapwood'] 			 	     = {['name'] = 'scrapwood', 					['label'] = 'Broken Peice of Wood', 	['weight'] = 50, 		['type'] = 'item', 		['image'] = 'scrapwood.png', 		['unique'] = false,		['useable'] = false, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Karate chopped wood'},
['cardboard'] 			 	     = {['name'] = 'cardboard', 					['label'] = 'Ripped Cardboard', 	    ['weight'] = 50, 		['type'] = 'item', 		['image'] = 'cardboard.png', 		['unique'] = false,		['useable'] = false,  	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Ripped Cardboard'},
['ducttape'] 				     = {['name'] = 'ducttape', 			  	  	    ['label'] = 'Duct Tape', 		        ['weight'] = 50, 		['type'] = 'item', 		['image'] = 'ducttape.png', 		['unique'] = false, 	['useable'] = false,  	['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'Roll of Duct Tape'},
['wires'] 			 	         = {['name'] = 'wires', 			  		    ['label'] = 'Electrical Wires', 		['weight'] = 50, 		['type'] = 'item', 		['image'] = 'wires.png', 		    ['unique'] = false,		['useable'] = false,  	['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'Torn Electrical Wires'},
```

## ⚙️ Configuration
Everything is in `config.lua`. Highlights:

| Option | What it does |
| --- | --- |
| `Config.Props` | Models that can be searched |
| `Config.ResetOnReboot` / `Config.ResetTime` | When a searched dumpster can be searched again |
| `Config.Minigame` | `false`, `'qb-lock'`, `'memorygame'` or `'ps-ui'` |
| `Config.Storage` | Let players store items in dumpsters |
| `Config.Illegal` / `Config.AlertChance` | Send a police alert when searching |
| `Config.Dispatch.Function` | Which dispatch the alert uses. community_bridge by default; a tk_dispatch example is included |
| `Config.Hurting` / `Config.CanBleed` | Chance to get hurt / bleed while searching |
| `Config.LootTiers` | Loot tables |
| `Config.ItemsSell` | What homeless peds buy, and for how much |
| `Config.BumSteal` / `Config.ItemsSteal` | Homeless peds stealing from you |

## 🆕 Changes in 1.1.0
- Runs on Qbox, QBCore and ESX through community_bridge (no qb-core / qb-target requirement).
- The police alert is a config function (any dispatch).
- Fixed an invalid `Config.ItemsSteal` entry; homeless peds can't be made to steal through a client event; each dumpster can only be looted once per reset.

<!-- gldnrmz-links -->
---

## 🔗 Links

<p align="center">
  <a href="https://discord.gg/7YHJ7774jA"><img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord" /></a>
  <a href="https://forum.cfx.re/u/gldnrmz/summary"><img src="https://img.shields.io/badge/Cfx.re-F40552?style=for-the-badge&logoColor=white" alt="Cfx.re forum" /></a>
  <a href="https://5metrics.dev/resources?search=gldnrmz"><img src="https://img.shields.io/badge/5Metrics-00BFFF?style=for-the-badge&logoColor=white" alt="5Metrics" /></a>
  <a href="https://gldnrmz.tebex.io"><img src="https://img.shields.io/badge/Tebex-FFD700?style=for-the-badge&logoColor=black" alt="Tebex store" /></a>
  <a href="https://www.buymeacoffee.com/gldnrmz"><img src="https://img.shields.io/badge/Buy%20me%20a%20coffee-FF813F?style=for-the-badge&logo=buymeacoffee&logoColor=white" alt="Buy me a coffee" /></a>
</p>
