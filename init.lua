
local S = minetest.get_translator("talkers")

local path = minetest.get_modpath("talkers")

talkers = {}

local http = core.request_http_api()
assert(http)

local system
local user

local function insertarSaltosDeLinea(texto, longitud)
	local resultado = {}
	for i = 1, #texto, longitud do
		table.insert(resultado, texto:sub(i, i + longitud - 1))
	end
	return table.concat(resultado, "\n")
end

function talkers.register_talker(name, register_mob, characters, tool, url, ai, wait)

	local current_modname = minetest.get_current_modname()
	
	local original_order = register_mob.order
	
	talkers[current_modname] = {}
	talkers[current_modname].after = {}
	talkers[current_modname].id = {}

	local original_on_rightclick = register_mob.on_rightclick
	
	register_mob.on_rightclick = function(self, clicker)
		
		if original_on_rightclick then
			local result = original_on_rightclick(self, clicker)
			if result == true then
				return
			end
		end
		
		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()
		
		talkers[current_modname].id[name] = self

		if item:get_name() == (tool)
		and (self.owner == name or
		minetest.check_player_privs(clicker, {protection_bypass = true}) )then

			minetest.show_formspec(name, current_modname .. ":indications",
						"size[6.3,1.1]" ..
						"button[0.2,0.2;2,1;wander;" .. S("Wander") .. "]" ..
						"button[2.2,0.2;2,1;stand;" .. S("Stand") .. "]" ..
						"button[4.2,0.2;2,1;follow;" .. S("Follow") .. "]")

			return
		end

		self.order = "stand"
		self:set_animation("stand")
		
		minetest.show_formspec(name, current_modname .. ":loading",
			"size[8,6]" ..
			"allow_close[false]" ..
			"label[3.4,2.5;" .. S("Loading...") .. "]")
			
		for index, value in ipairs(characters) do
			if characters[index].texture == talkers[current_modname].id[name].textures[1] then
				system = characters[index].system
				user = characters[index].user
			end
		end

		http.fetch({
			method = "POST",
			url = url,
			data = core.write_json({ model = ai, messages = { { role = "system", content = system .. " Respond in " .. S("English") }, { role = "user", content = user } }, stream = false })
		},
		function(chat_respond)

			chat_respond.data = core.parse_json(chat_respond.data)

			if chat_respond.data.done == true then
			
				res = chat_respond.data.message.content:gsub("<think>.-</think>", "")
				res = insertarSaltosDeLinea(res, 70)
				
				if talkers[current_modname].after[name] then
					talkers[current_modname].after[name]:cancel()
				end
				
				talkers[current_modname].after[name] = minetest.after(wait, function()
					self.order = register_mob.order
					minetest.close_formspec(name, current_modname .. ":chat")
				end)
				
				minetest.show_formspec(name, current_modname .. ":chat",
				"size[8,6]" ..
				"label[0.3,-0.5;" .. res .. "]" ..
				"field[2,3;4.5,1;input_text;" .. S("Write here:") .. ";]" ..
				"button[3,4;2,1;send;" .. S("Send") .. "]")
			end
		end)
	end

	mobs:register_mob(current_modname .. ":" .. name, register_mob)
	
	minetest.register_on_player_receive_fields(function(player, formname, fields)

		local name = player:get_player_name()
		
		if formname == current_modname .. ":chat" then
			if fields["send"] then
			
				minetest.show_formspec(name, current_modname .. ":loading",
					"size[8,6]" ..
					"allow_close[false]" ..
					"label[3.4,2.5;" .. S("Loading...") .. "]")
					
				for index, value in ipairs(characters) do
					if characters[index].texture == talkers[current_modname].id[name].textures[1] then
						system = characters[index].system
						user = characters[index].user
					end
				end
			
				http.fetch({
					method = "POST",
					url = url,
					data = core.write_json({ model = ai, messages = { { role = "system", content = system .. " Respond in " .. S("English") }, { role = "user", content = string.gsub(fields["input_text"], "/", "") } }, stream = false })
				},
				function(chat_respond)
					chat_respond.data = core.parse_json(chat_respond.data)
					if chat_respond.data.done == true then
						res = chat_respond.data.message.content:gsub("<think>.-</think>", "")
						res = insertarSaltosDeLinea(res, 70)
						
						if talkers[current_modname].after[name] then
							talkers[current_modname].after[name]:cancel()
						end
						
						talkers[current_modname].after[name] = minetest.after(wait, function()
							minetest.close_formspec(name, current_modname .. ":chat")
							talkers[current_modname].id[name].order = original_order
						end)
						
						minetest.show_formspec(name, current_modname .. ":chat",
						"size[8,6]" ..
						"label[0.3,-0.5;" .. res .. "]" ..
						"field[2,3;4.5,1;input_text;" .. S("Write here:") .. ";]" ..
						"button[3,4;2,1;send;" .. S("Send") .. "]")
					end
				end)
			end
		end
		
		if formname == current_modname .. ":indications" then
			if fields["stand"] then
				talkers[current_modname].id[name].order = "stand"
				minetest.close_formspec(name, current_modname .. ":indications")
			elseif fields["follow"] then
				talkers[current_modname].id[name].order = "follow"
				minetest.close_formspec(name, current_modname .. ":indications")
			elseif fields["wander"] then
				talkers[current_modname].id[name].order = "wander"
				minetest.close_formspec(name, current_modname .. ":indications")
			end
		end

	end)

	mobs:register_mob(current_modname .. ":" .. name, register_mob)
end

dofile(path .. "/talkers.lua")
