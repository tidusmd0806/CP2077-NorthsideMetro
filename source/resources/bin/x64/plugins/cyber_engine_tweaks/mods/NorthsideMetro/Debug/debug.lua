local Debug = {}
Debug.__index = Debug

function Debug:New(core_obj)
    local obj = {}
    obj.core_obj = core_obj

    -- set parameters
    obj.is_im_gui_player_local = false
    obj.is_set_observer = false
    obj.is_im_gui_line_info = false
    obj.is_im_gui_station_info = false
    obj.is_im_gui_measurement = false
    obj.is_im_gui_ristrict = false
    return setmetatable(obj, self)
end

function Debug:ImGuiMain()

    ImGui.Begin("Northside Metro DEBUG WINDOW")
    ImGui.Text("Debug Mode : On")

    self:SetObserver()
    self:SetLogLevel()
    self:SelectPrintDebug()
    self:ImGuiPlayerPosition()
    self:ImGuiLineInfo()
    self:ImGuiExcuteFunction()
    ImGui.End()

end

function Debug:SetObserver()

    if not self.is_set_observer then
        -- reserved
        -- Observe("DataTerm", "OnAreaEnter", function(this, evt)
        --     print("DataTerm OnAreaEnter")
        --     -- print(evt.componentName)
        --     -- this:OpenSubwayGate()
        -- end)
        -- Observe("FastTravelSystem", "QueueRequest", function(this, evt)
        --     print("FastTravelSystem QueueRequest")
        --     print(evt:ToString())
        -- end)
        -- Observe("QuestsSystem", "SetFact", function(this, factName, value)
        --     if string.find(factName.value, "ue_metro") then
        --         print('SetFact')
        --         print(factName.value)
        --         print(value)
        --     end
        -- end)
    end
    self.is_set_observer = true

    if self.is_set_observer then
        ImGui.SameLine()
        ImGui.Text("Observer : On")
    end

end

function Debug:SetLogLevel()
    function GetKeyFromValue(table_, target_value)
        for key, value in pairs(table_) do
            if value == target_value then
                return key
            end
        end
        return nil
    end
    function GetKeys(table_)
        local keys = {}
        for key, _ in pairs(table_) do
            table.insert(keys, key)
        end
        return keys
     end
    local selected = false
    if ImGui.BeginCombo("LogLevel", GetKeyFromValue(LogLevel, MasterLogLevel)) then
		for _, key in ipairs(GetKeys(LogLevel)) do
			if GetKeyFromValue(LogLevel, MasterLogLevel) == key then
				selected = true
			else
				selected = false
			end
			if(ImGui.Selectable(key, selected)) then
				MasterLogLevel = LogLevel[key]
			end
		end
		ImGui.EndCombo()
	end
end

function Debug:SelectPrintDebug()
    PrintDebugMode = ImGui.Checkbox("Print Debug Mode", PrintDebugMode)
end

function Debug:ImGuiPlayerPosition()
    self.is_im_gui_player_local = ImGui.Checkbox("[ImGui] Player Info", self.is_im_gui_player_local)
    if self.is_im_gui_player_local then
        local player = Game.GetPlayer()
        if player == nil then
            return
        end
        local player_pos = player:GetWorldPosition()
        local x_lo = string.format("%.2f", player_pos.x)
        local y_lo = string.format("%.2f", player_pos.y)
        local z_lo = string.format("%.2f", player_pos.z)
        ImGui.Text("Player World Pos : " .. x_lo .. ", " .. y_lo .. ", " .. z_lo)
        local player_quot = player:GetWorldOrientation()
        local player_angle = player_quot:ToEulerAngles()
        local roll = string.format("%.2f", player_angle.roll)
        local pitch = string.format("%.2f", player_angle.pitch)
        local yaw = string.format("%.2f", player_angle.yaw)
        ImGui.Text("Player World Angle : " .. roll .. ", " .. pitch .. ", " .. yaw)
        ImGui.Text("Player world Quot : " .. player_quot.i .. ", " .. player_quot.j .. ", " .. player_quot.k .. ", " .. player_quot.r)
    end
end

function Debug:ImGuiLineInfo()
    self.is_im_gui_line_info = ImGui.Checkbox("[ImGui] Line Info", self.is_im_gui_line_info)
    if self.is_im_gui_line_info then
        local active_station = Game.GetQuestsSystem():GetFact(CName.new("ue_metro_active_station"))
        local next_station = Game.GetQuestsSystem():GetFact(CName.new("ue_metro_next_station"))
        local line = Game.GetQuestsSystem():GetFact(CName.new("ue_metro_track_selected"))
        local is_stopped_st = Game.GetQuestsSystem():GetFact(CName.new("ue_metro_stopped_at_station"))
        local is_arriving = Game.GetQuestsSystem():GetFact(CName.new("ue_metro_arriving_at_station"))
        ImGui.Text("Activate Station : " .. active_station)
        ImGui.Text("Next Station : " .. next_station)
        ImGui.Text("Line : " .. line)
        ImGui.Text("is_stopped_st : " .. is_stopped_st)
        ImGui.Text("is_arriving : " .. is_arriving)
    end
end

function Debug:ImGuiExcuteFunction()
    if ImGui.Button("TF1") then
        local look_at_obj = Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer())
        print(look_at_obj:GetClassName())
        if look_at_obj:IsA("DataTerm") then
            local comp = look_at_obj:FindComponentByName(CName.new("collider"))
            if comp ~= nil then
                print("collider")
            end
        end
        print("Excute Test Function 1")
    end
    ImGui.SameLine()
    if ImGui.Button("TF2") then
        print("Excute Test Function 2")
    end

    ImGui.SameLine()
    if ImGui.Button("TF3") then
        local pos = Game.GetPlayer():GetWorldPosition()
        local pos_base = Vector4.new(-1832.47998, 2147.79004, 37.4199982, 1)
        local absolute_pos = Vector4.new(pos.x - pos_base.x, pos.y - pos_base.y, pos.z - pos_base.z, 1)
        print(absolute_pos.x .. ", " .. absolute_pos.y .. ", " .. absolute_pos.z)
        print("Excute Test Function 3")
    end

    ImGui.SameLine()
    if ImGui.Button("TF4") then
        local pos = Game.GetPlayer():GetWorldPosition()
        local pos_base = Vector4.new(-2016.43994, 2815.61987, 29.1299992, 1)
        local absolute_pos = Vector4.new(pos.x - pos_base.x, pos.y - pos_base.y, pos.z - pos_base.z, 1)
        print(absolute_pos.x .. ", " .. absolute_pos.y .. ", " .. absolute_pos.z)
        print("Excute Test Function 4")
    end

    ImGui.SameLine()
    if ImGui.Button("TF5") then
        local pos = Game.GetPlayer():GetWorldPosition()
        local pos_base = Vector4.new(-749.4100, 2204.3799, 68.2600, 1)
        local absolute_pos = Vector4.new(pos.x - pos_base.x, pos.y - pos_base.y, pos.z - pos_base.z, 1)
        print(absolute_pos.x .. ", " .. absolute_pos.y .. ", " .. absolute_pos.z)
        print("Excute Test Function 5")
    end
end

return Debug
