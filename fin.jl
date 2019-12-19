using Discord
include("base.jl")

function fin(client::Client,m::Message,damage::Int)
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

    remain_hp = management_dict[channel_id_str]["reserve"][boss_number]["remain_hp"] - damage

    if remain_hp <0
        return reply(client,m,"ボスを討伐した場合には`.la`コマンドを使用して下さい")
    end

    management_dict[channel_id_str]["reserve"][boss_number]["remain_hp"] = remain_hp
    deleteat!(management_dict[channel_id_str]["reserve"][boss_number]["reserve_list"],dict_number)
    management_dict[channel_id_str]["reserve"][boss_number]["plan_remain_hp"] = calc_plan_remain_hp(management_dict[channel_id_str]["reserve"][boss_number])

    output_message_content = create_output_message(management_dict[channel_id_str])
    edit_message(client,management_dict[channel_id_str]["output_channel"],management_dict[channel_id_str]["output_message"],content=output_message_content)

    #残凸状況を修正
    if management_dict[channel_id_str]["remain_attack"][string(m.author.id)]["remain"] > 0
        management_dict[channel_id_str]["remain_attack"][string(m.author.id)]["remain"] -= 1
        management_dict[channel_id_str]["remain_attack"][string(m.author.id)]["over"] = false
        management_dict[channel_id_str]["remain_attack"][string(m.author.id)]["over_content"]  = ""
        remain_attack_message_content = make_remain_attack_message_content(management_dict[channel_id_str]["remain_attack"],management_dict[channel_id_str]["today"])
        edit_message(client,management_dict[channel_id_str]["remain_attack_channel"],management_dict[channel_id_str]["remain_attack_message"],content=remain_attack_message_content)
    end

    save_management_dict(management_dict)
    create(client, Reaction, m, '👍')

end
