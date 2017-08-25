ignored = {}
function ignored.add_player(invoker, target)
	local player = minetest.get_player_by_name(invoker)
	local currently_ignored = player:get_attribute("ignored:players")
	local ignored_table = minetest.deserialize(currently_ignored) or {}
	table.insert(ignored_table, target)
	player:set_attribute("ignored:players", minetest.serialize(ignored_table))
end
function ignored.remove_player(invoker, target)
	local player = minetest.get_player_by_name(invoker)
	local currently_ignored = player:get_attribute("ignored:players")
	local ignored_table = minetest.deserialize(currently_ignored) or {}
	local removed_entries = 0
	for i = 0, #ignored_table do
		if ignored_table[i] == target then
			table.remove(ignored_table, i)
			removed_entries = removed_entries + 1
		end
	end
	player:set_attribute("ignored:players", minetest.serialize(ignored_table))
	return removed_entries
end
function ignored.get_players(invoker)
	local player = minetest.get_player_by_name(invoker)
	return minetest.deserialize(player:get_attribute("ignored:players"))
end
minetest.register_chatcommand("ignore", {
	params = "<name>",
	description = "Ignore a player",
	func = function(name, text)
		ignored.add_player(name, text)
		return true, "Player ignored."
	end,
})
minetest.register_chatcommand("unignore", {
	params = "<name>",
	description = "Stop ignoring a player",
	func = function(name, text)
		local number_entries = ignored.remove_player(name, text)
		return true, "Removed " .. number_entries .. " entries."
	end,
})
minetest.register_chatcommand("get_ignored", {
	description = "Get ignored players",
	func = function(name)
		return true, "Ignored players: " .. minetest.serialize(ignored.get_players(name))
	end,
})
core.register_on_chat_message(function(sender, message)
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local players = ignored.get_players(name)
		if players == 0 then
			minetest.chat_send_player(name, "<" .. sender .. "> " .. message)
			return true
		else
			for i = 1, #players do
				if players[i] == sender then
					return true
				else
					minetest.chat_send_player(name, "<" .. sender .. "> " .. message)
					return true
				end
			end
		end
	end
end)
