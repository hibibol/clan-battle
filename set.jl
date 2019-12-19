using Discord
using JSON
include("base.jl")


#management_dict = Dict()

#@show management_dict
function set_channel_id(client::Client,m::Discord.Message,channel_name,channel_mention)
    global management_dict
    if "<#" != channel_mention[1:2]
        return reply(client,m,"`$(channel_mention)` は適切に入力されていません．リンク付きのチャンネルを入力してください")
    end
    channel_mention_id = parse(Int,channel_mention[3:length(channel_mention)-1])
    input_channel_id = string(m.channel_id)

    if !haskey(management_dict,input_channel_id)
        management_dict[input_channel_id] = Dict("guild_id" => m.guild_id)
    end

    if channel_name  == "残凸把握板"
        management_dict[input_channel_id]["remain_attack_channel"] = channel_mention_id
        save_management_dict(management_dict)
        return reply(client,m,"残凸把握版を$(channel_mention)に登録しました")

    elseif channel_name == "タスキル把握板"
        management_dict[input_channel_id]["task_kill_channel"] = channel_mention_id
        save_management_dict(management_dict)
        return reply(client,m,"タスキル把握版を$(channel_mention)に登録しました")

    elseif channel_name == "予約確認板"
        management_dict[input_channel_id]["output_channel"] = channel_mention_id
        save_management_dict(management_dict)
        return reply(client,m,"予約確認版を$(channel_mention)に登録しました")
    else
        return reply(client,m,"チャンネルの種類が適切に入力されておりません(`$(channel_name)`)．`残凸把握板` `予約確認板`のいずれかを入力してください")
    end
end
