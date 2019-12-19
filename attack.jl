using Discord
include("base.jl")

function attack(client::Client,m::Message)
    global management_dict


    no_reserve = true

    channel_id_str = string(m.channel_id)

    if !haskey(management_dict,channel_id_str)
        return reply(client,m,"初期設定が完了しておりません．`.set`コマンドにて初期設定を完了させてください")
    end

    if !haskey(management_dict[channel_id_str],"remain_attack_channel")
        return reply(client,m,"残凸把握板の登録が完了しておりません．`.set`コマンドにて初期設定を完了させてください")
    end

    if  !haskey(management_dict[channel_id_str],"output_channel")
        return reply(client,m,"予約確認板の登録が完了しておりません．`.set`コマンドにて初期設定を完了させてください")
    end

    boss_number = string(management_dict[channel_id_str]["boss_number"])
    reserve_list =  management_dict[channel_id_str]["reserve"][boss_number]["reserve_list"]

    #予約中の人を探してフラグを付け替える
    for i = 1:length(reserve_list)
        if reserve_list[i]["id"] == m.author.id
            management_dict[channel_id_str]["reserve"][boss_number]["reserve_list"][i]["attack"] = true
            no_reserve = false
            break
        end
    end

    #予約していなかったら怒る
    if no_reserve
        return reply(client,m,"予約されていません.")
    end

    output_message_content = create_output_message(management_dict[channel_id_str])
    edit_message(client,management_dict[channel_id_str]["output_channel"],management_dict[channel_id_str]["output_message"],content=output_message_content)

    dt_now =now(tz"Asia/Tokyo") - Hour(5)
    dt_now_str = "$(month(dt_now))月$(day(dt_now))日"
    if dt_now_str != management_dict[channel_id_str]["today"]#日付が変わっていれば残凸状況を修正する
        management_dict[channel_id_str]["today"] = dt_now_str
        management_dict[channel_id_str]["remain_attack"] =initiate_remain_attack_dict(client,management_dict[channel_id_str])
        remain_attack_message_content = make_remain_attack_message_content(management_dict[channel_id_str]["remain_attack"],management_dict[channel_id_str]["today"])
        remain_attack_message = fetchval(create_message(client,management_dict[channel_id_str]["remain_attack_channel"],content=remain_attack_message_content))

        management_dict[channel_id_str]["remain_attack_message"] = remain_attack_message.id
    end

    save_management_dict(management_dict)
    create(client, Reaction, m, '👍')
end
