using Discord
include("base.jl")

function la(client::Client,m::Message;over_time="")
    global  management_dict

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
    if !management_dict[channel_id_str]["remain_attack"][string(m.author.id)]["over"] && length(over_time) == 0
        return reply(client,m,"持ち越しした場合には`.la [持ち越し時間]`を送信して下さい")
    end
    boss_number = string(management_dict[channel_id_str]["boss_number"])
    reserve_list =  management_dict[channel_id_str]["reserve"][boss_number]["reserve_list"]


    dict_number = 0

    #予約ずみかどうか事前に凸宣言をしていたかどうかをチェックする
    for i = 1:length(reserve_list)
        if reserve_list[i]["id"] == m.author.id
            if !reserve_list[i]["attack"]
                return reply(client,m,"凸宣言がされておりません．`.attack`コマンドにて宣言を行って下さい")
            end
            dict_number = i
        end
    end

    #予約していなかっtら怒る
    if dict_number == 0
        return reply(client,m,"凸予約がされていません.")
    end

    next_boss_number = management_dict[channel_id_str]["boss_number"]+1
    management_dict[channel_id_str]["reserve"][boss_number] =  Dict(
        "reserve_list" => [],
        "plan_remain_hp" => get_default_hp(management_dict[channel_id_str]["lap"]+1,management_dict[channel_id_str]["boss_number"]),
        "remain_hp" => get_default_hp(management_dict[channel_id_str]["lap"]+1,management_dict[channel_id_str]["boss_number"])
    )

    if next_boss_number == 6
        next_boss_number =1
        management_dict[channel_id_str]["lap"] += 1
    end

    management_dict[channel_id_str]["boss_number"] =next_boss_number

    output_message_content = create_output_message(management_dict[channel_id_str])
    edit_message(client,management_dict[channel_id_str]["output_channel"],management_dict[channel_id_str]["output_message"],content=output_message_content)

    #次の人に通知を行う
    notify_message = ""

    for next_reserve_dict in management_dict[channel_id_str]["reserve"][string(next_boss_number)]["reserve_list"]
        notify_message *= "<@!$(next_reserve_dict["id"])> "
    end

    if notify_message != ""
        notify_message *= "\n$(Boss_dict["normal"][next_boss_number].name)になりました．"
        reply(client,m,notify_message)
    end

    #残凸状況を修正，持ち越ししていることを把握する
    if management_dict[channel_id_str]["remain_attack"][string(m.author.id)]["remain"] > 0 &&  length(over_time) >0
        management_dict[channel_id_str]["remain_attack"][string(m.author.id)]["over"] = true
        management_dict[channel_id_str]["remain_attack"][string(m.author.id)]["over_content"]  = "$(Boss_dict["normal"][int(boss_number)].name) $(over_time)"
        remain_attack_message_content = make_remain_attack_message_content(management_dict[channel_id_str]["remain_attack"],management_dict[channel_id_str]["today"])
        edit_message(client,management_dict[channel_id_str]["remain_attack_channel"],management_dict[channel_id_str]["remain_attack_message"],content=remain_attack_message_content)
    end

    save_management_dict(management_dict)
    create(client, Reaction, m, '👍')

end
