serpent = require("serpent")

--json = (loadfile "./libs/JSON.lua")()

function dl_cb (arg, data)
end

function vardump(value, depth, key)
   local linePrefix = ""
   local spaces = ""

   if key ~= nil then
      linePrefix = "["..key.."] = "
   end

   if depth == nil then
      depth = 0
   else
      depth = depth + 1
      for i=1, depth do spaces = spaces .. "  " end
   end

   if type(value) == 'table' then
      mTable = getmetatable(value)
      if mTable == nil then
         print(spaces ..linePrefix.."(table) ")
      else
         print(spaces .."(metatable) ")
         value = mTable
      end
      for tableKey, tableValue in pairs(value) do
         vardump(tableValue, depth, tableKey)
      end
   elseif type(value)  == 'function' or type(value) == 'thread' or type(value) == 'userdata' or value == nil then
      print(spaces..tostring(value))
   else
      print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
   end
end

function ok_cb(extra, success, result)

end

function oldtg(data)
   local msg = {}
   msg.to = {}
   msg.from = {}
   msg.replied = {}

   msg.to.id = data.message_.chat_id_
   msg.from.id = data.message_.sender_user_id_
   if data.message_.content_.ID == "MessageText" then
      msg.text = data.message_.content_.text_
   end
   if data.message_.content_.caption_ then
      msg.text = data.message_.content_.caption_
   end
   msg.date = data.message_.date_
   msg.id = data.message_.id_
   msg.unread = false
   if data.message_.reply_to_message_id_ == 0 then
      msg.reply_id = false
   else
      msg.reply_id = data.message_.reply_to_message_id_
   end
   if data.message_.content_.ID == "MessagePhoto" then
      msg.photo = true
   else
      msg.photo = false
   end
   if data.message_.content_.ID == "MessageSticker" then
      msg.sticker = true
   else
      msg.sticker = false
   end
   if data.message_.content_.ID == "MessageAudio" then
      msg.audio = true
   else
      msg.audio = false
   end
   if data.message_.content_.ID == "MessageVoice" then
      msg.voice = true
   else
      msg.voice = false
   end
   if data.message_.content_.ID == "MessageAnimation" then
      msg.gif = true
   else
      msg.gif = false
   end
   if data.message_.content_.ID == "MessageVideo" then
      msg.video = true
   else
      msg.video = false
   end
   if data.message_.content_.ID == "MessageDocument" then
      msg.document = true
   else
      msg.document = false
   end
   if data.message_.content_.ID == "MessageGame" then
      msg.game = true
   else
      msg.game = false
   end
   if data.message_.forward_info_ then
      msg.forward = true
      msg.forward = {}
      msg.forward.from_id = data.message_.forward_info_.sender_user_id_
      msg.forward.msg_id = data.message_.forward_info_.data_
   else
      msg.forward = false
   end
   if data.message_.content_.ID then
      msg.action = data.message_.content_.ID
   end
   if data.message_.content_.ID == "MessageChatAddMembers" or data.message_.content_.ID == "MessageChatDeleteMember" or
   data.message_.content_.ID == "MessageChatChangeTitle" or data.message_.content_.ID == "MessageChatChangePhoto" or
   data.message_.content_.ID == "MessageChatJoinByLink" or data.message_.content_.ID == "MessageGameScore" then
      msg.service = true
   else
      msg.service = false
   end
   local new_members = data.message_.content_.members_
   if new_members then
      msg.added = {}
      for i = 0, #new_members, 1 do
         k = i+1
         msg.added[k] = {}
         if new_members[i].username_ then
            msg.added[k].username = new_members[i].username_
         else
            msg.added[k].username = false
         end
         msg.added[k].first_name = new_members[i].first_name_
         if new_members[i].last_name_ then
            msg.added[k].last_name = new_members[i].last_name_
         else
            msg.added[k].last_name = false
         end
      end
   end
   return msg
end

function user_data(msg, data)
   if data.username_ then
      msg.from.username = data.username_
   else
      msg.from.username = false
   end
   msg.from.first_name = data.first_name_
   if data.last_name_ then
      msg.from.last_name = data.last_name_
   else
      msg.from.last_name = false
   end
   if msg.action == "MessageChatJoinByLink" then
      msg.added = {}
      msg.added[1] = {}
      msg.added[1].username = msg.from.username
      msg.added[1].first_name = msg.from.fist_name
      msg.added[1].last_name = msg.from.last_name
   end
   return msg
end

function reply_data(msg, data)
   if data.username_ then
      msg.replied.username = data.username_
   end
   msg.replied.first_name = data.first_name_
   if data.last_name_ then
      msg.replied.last_name = data.last_name_
   end
   return msg
end

function return_media(msg)
   if msg.photo then
      return "MessagePhoto"
   elseif msg.sticker then
      return "MessageSticker"
   elseif msg.audio then
      return "MessageAudio"
   elseif msg.voice then
      return "MessageVoice"
   elseif msg.gif then
      return "MessageAnimation"
   elseif msg.text then
      return "MessageText"
   elseif msg.service then
      return "MessageService"
   elseif msg.video then
      return "MessageVideo"
   elseif msg.document then
      return "MessageDocument"
   elseif msg.game then
      return "MessageGame"
   end
end

function serialize_to_file(data, file, uglify)
   file = io.open(file, 'w+')
   local serialized
   if not uglify then
      serialized = serpent.block(data, {
         comment = false,
         name = '_'
      })
   else
      serialized = serpent.dump(data)
   end
   file:write(serialized)
   file:close()
end

-- Returns a table with matches or nil
function match_pattern(pattern, text, lower_case)
   if text then
      local matches = {}
      if lower_case then
         matches = { string.match(text:lower(), pattern) }
      else
         matches = { string.match(text, pattern) }
      end
      if next(matches) then
         return matches
      end
   end
   -- nil
end

function get_receiver(msg)
   return msg.to.id

end

function getChatId(chat_id)
   local chat = {}
   local chat_id = tostring(chat_id)

   if chat_id:match('^-100') then
      local channel_id = chat_id:gsub('-100', '')
      chat = {ID = channel_id, type = 'channel'}
   else
      local group_id = chat_id:gsub('-', '')
      chat = {ID = group_id, type = 'group'}
   end

   return chat
end

function set_text(lang, keyword, text)
   local hash = 'lang:'..lang..':'..keyword
   redis:set(hash, text)
end

function is_mod(chat_id, user_id)
   local hash = 'mod:'..chat_id..':'..user_id
   if redis:get(hash) then
      return true
   else
      return false
   end
end

function is_admin(user_id)
   local hash = 'admin:' .. user_id
   if redis:get(hash) then
      return true
   else
      return false
   end
end

function new_is_sudo(user_id)
   local var = false
   -- Check users id in config
   for v,user in pairs(_config.sudo_users) do
      if user == user_id then
         var = true
      end
   end
   return var
end

function lang_text(chat_id, keyword)
   local hash = 'langset:'..chat_id
   local lang = redis:get(hash)
   if not lang then
      redis:set(hash,'en')
      lang = redis:get(hash)
   end
   local hashtext = 'lang:'..lang..':'..keyword
   if redis:get(hashtext) then
      return redis:get(hashtext)
   else
      return 'Please, install your selected "'..lang..'" language by #install [`archive_name(english_lang, spanish_lang...)`]. First, active your language package like a normal plugin by it\'s name. For example, #plugins enable `english_lang`. Or set another one by typing #lang [language(en, es...)].'
   end

end

function is_number(name_id)
   if tonumber(name_id) then
      return true
   else
      return false
   end
end

function no_markdown(text, replace)
   if text then
      text = tostring(text)
      if replace then
         text = text:gsub("`", replace)
         text = text:gsub("*", replace)
         text = text:gsub("_", replace)
         return text
      end
      text = text:gsub("`", "")
      text = text:gsub("*", "")
      text = text:gsub("_", "")
      return text
   end
   return false
end

function send_large_msg(chat_id, text)
   local text_len = string.len(text)
   local text_max = 4096
   local times = text_len/text_max
   local text = text
   for i = 1, times, 1 do
      local text = string.sub(text, 1, 4096)
      local rest = string.sub(text, 4096, text_len)
      local destination = chat_id
      local num_msg = math.ceil(text_len / text_max)
      if num_msg <= 1 then
         send_msg(destination, text, 'md')
      else
         text = rest
      end
   end
end
