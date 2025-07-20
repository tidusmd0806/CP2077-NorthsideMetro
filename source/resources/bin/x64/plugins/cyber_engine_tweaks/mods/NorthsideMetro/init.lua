--------------------------------------------------------
-- CopyRight (C) 2025, tidusmd. All rights reserved.
-- This mod is under the MIT License.
-- https://opensource.org/licenses/mit-license.php
--------------------------------------------------------

Cron = require('External/Cron.lua')
Log = require("Debug/log.lua")

local Debug = require('Debug/debug.lua')

NSM = {
	description = "Northside Metro",
	version = "1.0.3",
    is_debug_mode = false,
    -- version check
    cet_required_version = 36.0, -- 1.36.0
    cet_version_num = 0,
}

registerForEvent("onTweak",function ()
    -- anygoodname: adding supporting TweakDB entries to remove Tweak XL dependancy:
    if not TweakDB:GetRecord("FastTravelPoints.wat_nid_metro_ftp_20") then
        TweakDB:CloneRecord("FastTravelPoints.wat_nid_metro_ftp_20", "FastTravelPoints.wat_nid_metro_ftp_01")
    end
    TweakDB:SetFlat("FastTravelPoints.wat_nid_metro_ftp_20.displayName", "LocKey#20480")
    TweakDB:SetFlat("FastTravelPoints.wat_nid_metro_ftp_20.district", TweakDBID.new("Districts.ArasakaWaterfront"))

    if not TweakDB:GetRecord("FastTravelPoints.wat_nid_metro_ftp_21") then
        TweakDB:CloneRecord("FastTravelPoints.wat_nid_metro_ftp_21", "FastTravelPoints.wat_nid_metro_ftp_01")
    end
    TweakDB:SetFlat("FastTravelPoints.wat_nid_metro_ftp_21.displayName", "LocKey#39940")
    TweakDB:SetFlat("FastTravelPoints.wat_nid_metro_ftp_21.district", TweakDBID.new("Districts.Northside"))

    if not TweakDB:GetRecord("FastTravelPoints.wat_nid_metro_ftp_22") then
        TweakDB:CloneRecord("FastTravelPoints.wat_nid_metro_ftp_22", "FastTravelPoints.wat_nid_metro_ftp_01")
    end
    TweakDB:SetFlat("FastTravelPoints.wat_nid_metro_ftp_22.displayName", "LocKey#21523")
    TweakDB:SetFlat("FastTravelPoints.wat_nid_metro_ftp_22.district", TweakDBID.new("Districts.Northside"))

    TweakDB:SetFlat("FastTravelPoints.wat_nid_dataterm_07.showInWorld", false)
    TweakDB:SetFlat("FastTravelPoints.wat_nid_dataterm_07.showOnWorldMap", false)
    ------------------------------------------------
end)

registerForEvent('onInit', function()

    if not NSM:CheckDependencies() then
        print('[Error] Northside Metro Mod failed to load due to missing dependencies.')
        return
    end

    NSM.debug_obj = Debug:New()
    NSM.log_obj = Log:New()
    NSM.log_obj:SetLevel(LogLevel.Info, "NSM")

    -- Delete All Foods Factory's Fast Travel Point
    Override("DataTerm", "RegisterMappin",
    ---@param this DataTerm
    ---@param wrapped_method function
    function(this, wrapped_method)
        local point_record = this.linkedFastTravelPoint.pointRecord
        if point_record == TweakDBID("FastTravelPoints.wat_nid_dataterm_07") then
            this:DeactivateDevice()
            EntityGameInterface.Destroy(this:GetEntity())
            NSM.log_obj:Record(LogLevel.Info, "Deleted All Foods Factory's Fast Travel Point")
            return
        end
        wrapped_method()
    end)

    -- Insert Desplay Text on Next Station
    ObserveAfter("NcartDoorScreenInkController", "ChangeNextStationName",
    ---@param this NcartDoorScreenInkController
    ---@param new_station Int32
    function(this, new_station)
        if new_station >= 20 then
            local text = GetLocalizedText("LocKey#20480")
            if new_station == 20 then
                text = GetLocalizedText("LocKey#20480")
            elseif new_station == 21 then
                text = GetLocalizedText("LocKey#39940")
            elseif new_station == 22 then
                text = GetLocalizedText("LocKey#21523")
            end
            Cron.Every(0.5, {tick=0}, function(timer)
                timer.tick = timer.tick + 1
                this.stationNameWidget:SetText(text)
                if timer.tick >= 3 then
                    NSM.log_obj:Record(LogLevel.Trace, "Inserted Desplay Text on Next Station: " .. text)
                    timer:Halt()
                end
            end)
        end
    end)

    -- Insert Diagram Text on Next Station
    ObserveAfter("NcartTrainLineListInkController", "MarkNextStationOnLine",
    ---@param this NcartTrainLineListInkController
    ---@param active_station Int32
    function(this, active_station)
        local line_num = Game.GetQuestsSystem():GetFact(CName.new("ue_metro_track_selected"))
        local is_reversed = Game.GetQuestsSystem():GetFact(CName.new("ue_metro_track_reverse"))
        if active_station == 2 and line_num == 1 and is_reversed == 1 then
            Cron.After(0.5, function()
                this:MarkStationActive(0)
                this.ncartLineStationList:GetWidget(0):GetWidget("StationNameCanvas"):GetWidget("StationNamePane"):GetWidget("StationNameWrapper"):GetWidget("StatioName"):SetText(GetLocalizedText("LocKey#20480"))
            end)
        elseif active_station == 20 and line_num == 1 and is_reversed == 1 then
            Cron.After(0.5, function()
                this:MarkStationActive(0)
                this.ncartLineStationList:GetWidget(0):GetWidget("StationNameCanvas"):GetWidget("StationNamePane"):GetWidget("StationNameWrapper"):GetWidget("StatioName"):SetText(GetLocalizedText("LocKey#39940"))
            end)
        elseif active_station == 21 and line_num == 1 and is_reversed == 1 then
            Cron.After(0.5, function()
                this:MarkStationActive(0)
                this.ncartLineStationList:GetWidget(0):GetWidget("StationNameCanvas"):GetWidget("StationNamePane"):GetWidget("StationNameWrapper"):GetWidget("StatioName"):SetText(GetLocalizedText("LocKey#21523"))
            end)
        elseif active_station == 22 and line_num == 1 and is_reversed == 0 then
            Cron.After(0.5, function()
                this:MarkStationActive(1)
                this.ncartLineStationList:GetWidget(1):GetWidget("StationNameCanvas"):GetWidget("StationNamePane"):GetWidget("StationNameWrapper"):GetWidget("StatioName"):SetText(GetLocalizedText("LocKey#39940"))
            end)
        elseif active_station == 21 and line_num == 1 and is_reversed == 0 then
            Cron.After(0.5, function()
                this:MarkStationActive(1)
                this.ncartLineStationList:GetWidget(1):GetWidget("StationNameCanvas"):GetWidget("StationNamePane"):GetWidget("StationNameWrapper"):GetWidget("StatioName"):SetText(GetLocalizedText("LocKey#20480"))
            end)
        elseif active_station == 20 and line_num == 1 and is_reversed == 0 then
            Cron.After(0.5, function()
                this:MarkStationActive(1)
                this.ncartLineStationList:GetWidget(1):GetWidget("StationNameCanvas"):GetWidget("StationNamePane"):GetWidget("StationNameWrapper"):GetWidget("StatioName"):SetText(GetLocalizedText("LocKey#49195"))
            end)
        end
        NSM.log_obj:Record(LogLevel.Debug, "Call MarkNextStationOnLine: " .. active_station .. ", " .. line_num .. ", " .. is_reversed)
    end)

    print('Northside Metro Mod is ready!')

end)

registerForEvent("onDraw", function()
    if NSM.is_debug_mode then
        if NSM.debug_obj ~= nil then
            NSM.debug_obj:ImGuiMain()
        end
    end
end)

registerForEvent('onUpdate', function(delta)
    Cron.Update(delta)
end)

function NSM:CheckDependencies()

    -- Check Cyber Engine Tweaks Version
    local cet_version_str = GetVersion()
    local cet_version_major, cet_version_minor = cet_version_str:match("1.(%d+)%.*(%d*)")
    NSM.cet_version_num = tonumber(cet_version_major .. "." .. cet_version_minor)

    if NSM.cet_version_num < NSM.cet_required_version then
        print("Northside Metro Mod requires Cyber Engine Tweaks version 1." .. NSM.cet_required_version .. " or higher.")
        return false
    end

    return true

end

return NSM