fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Dumpster diving and trash selling (Qbox, QBCore, ESX via community_bridge)'

client_script 'client/*.lua'
server_script 'server/*.lua'
shared_scripts {
    'shared/locale.lua',
    'locales/en.lua',
    'config.lua'
}

dependency 'community_bridge'
