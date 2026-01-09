fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DC Customz - Enhanced by AI'
description 'Advanced Props Attachment Tool with Presets, History, Mirror Mode & More'
version '2.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/index.js'
}

shared_scripts {
    '@ox_lib/init.lua',
    'cfg.lua'
}

client_scripts {
    'client.lua'
}

dependency 'ox_lib'