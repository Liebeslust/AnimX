util.keep_running()
util.require_natives("1676318796")

LOC = require "src.lib.misc.localization"
AnimXUtils = require "src.lib.utils"

AnimXDir = filesystem.store_dir() .. "AnimX\\"


require "src.lib.external.functions"
require "src.lib.misc.filelist"
require "src.lib.misc.labels"

require "src.lib.animlib.anim"

require "src.lib.actorlib.component"
require "src.lib.actorlib.group"
require "src.lib.actorlib.member"
require "src.lib.actorlib.models"
require "src.lib.actorlib.prop"
require "src.lib.actorlib.wardrobe"
require "src.lib.actorlib.weaponsMenu"

require "src.lib.animlib.animMenu"
require "src.lib.actor"

require "src.lib.menus"