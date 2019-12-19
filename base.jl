using JSON
using Dates
using TimeZones

include("boss.jl")
const management_json_file_name ="management.json"

f = open(management_json_file_name,"r")
management_dict = JSON.parse(f)
close(f)

function isdecimal(arg)
    try
        parse(Int,arg)
        return true
    catch ArgumentError
        return false
    end
end

function int(arg)
    return parse(Int,arg)
end


function save_management_dict(management_dict)
    open(management_json_file_name,"w") do f
        JSON.Writer.print(f,management_dict)
    end
end

function get_default_hp(lap,boss_number)
    if lap >= 11
        return Boss_dict["very_hard"][boss_number].hp
    else
        return  Boss_dict["normal"][boss_number].hp
    end
end

function arrange_reserve_list(reserve_list)
    text = ""
    if length(reserve_list) == 0
        return text
    end

    for reserve_dict in reserve_list
        if reserve_dict["over"]
            text *= "\t$(reserve_dict["name"]) $(reserve_dict["damage"]) 持ち越し $(reserve_dict["attack"]*"凸中")\n"
        end
    end

    for reserve_dict in reserve_list
        if !reserve_dict["over"]
            text *= "\t$(reserve_dict["name"]) $(reserve_dict["damage"]) $(reserve_dict["attack"]*"凸中")\n"
        end
    end

    return text
end

function create_output_message(channel_dict)
    boss_number =channel_dict["boss_number"]
    message_contetnt = """
    $(channel_dict["lap"])週目 現在のボスの予約状況は以下の通りです
    **$(Boss_dict["normal"][boss_number].name)** 残HP:$(channel_dict["reserve"][string(boss_number)]["remain_hp"])万
    凸終了後予定HP:$(channel_dict["reserve"][string(boss_number)]["plan_remain_hp"])万
    $(arrange_reserve_list(channel_dict["reserve"][string(boss_number)]["reserve_list"]))

    [凸予約状況]
    """

    for i = 1:4
        boss_number += 1
        boss_number = (boss_number>5) ? boss_number-5 : boss_number

        message_contetnt *=  """
        $(Boss_dict["normal"][boss_number].name)
        凸終了後予定残HP:$(channel_dict["reserve"][string(boss_number)]["plan_remain_hp"])万
        $(arrange_reserve_list(channel_dict["reserve"][string(boss_number)]["reserve_list"]))

        """
    end
    return message_contetnt

end

function get_display_name(message::Message)
    display_name = message.member.nick
    if display_name === missing
        display_name = message.author.username
    end
    return display_name
end

function get_display_name(member::Member)
    display_name = member.nick
    if display_name === missing
        display_name = member.user.username
    end
    return display_name
end

function calc_plan_remain_hp(reserve_boss_dict)
    #現在の残りHPから凸終了後予定HPを計算する
    plan_remain_hp = reserve_boss_dict["remain_hp"]

    reserve_list = reserve_boss_dict["reserve_list"]

    for reserve in reserve_list
        plan_remain_hp -= reserve["damage"]
    end

    if plan_remain_hp <0
        plan_remain_hp = 0
    end

    return plan_remain_hp
end

#残凸状況を記録するための辞書を保管
function initiate_remain_attack_dict(c::Client,channel_dict)

    guild  = fetchval(get_guild(c,channel_dict["guild_id"]))
    members = guild.members

    remain_attack_dict = Dict()
    for member in members
        if member.user.bot !== true
            remain_attack_dict[string(member.user.id)] = Dict(
                "remain" => 3,
                "name" => get_display_name(member),
                "over" => false,
                "over_content" => ""
            )
        end
    end

    return remain_attack_dict
end

function make_remain_attack_message_content(remain_attack_dict,date_string)
    content = " $(date_string) の凸状況です\n"

    for key in keys(remain_attack_dict)
        content *= "$(remain_attack_dict[key]["name"]) $(remain_attack_dict[key]["remain"]) $(remain_attack_dict[key]["over"]*"持ち越し") $(remain_attack_dict[key]["over_content"])\n"
    end

    return content
end
