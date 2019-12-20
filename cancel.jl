using Discord
include("base.jl")

function cancel(client::Client,m::Message,boss_number::Int)
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

    if boss_number > 5 || boss_number < 1
        return reply(client,m,"不正な入力です．[ボス番号:$(boss_number)は1から5である必要があります]")
    end

    boss_number = string(boss_number)
    reserve_list =  management_dict[channel_id_str]["reserve"][boss_number]["reserve_list"]


    dict_number = 0

    #予約ずみかどうかをチェックする
    for i = 1:length(reserve_list)
        if reserve_list[i]["id"] == m.author.id
            dict_number = i
            break
        end
    end

    #予約していなかっtら怒る
    if dict_number == 0
        return reply(client,m,"凸予約がされていません.")
    end


    deleteat!(management_dict[channel_id_str]["reserve"][boss_number]["reserve_list"],dict_number)
    management_dict[channel_id_str]["reserve"][boss_number]["plan_remain_hp"] = calc_plan_remain_hp(management_dict[channel_id_str]["reserve"][boss_number])

    output_message_content = create_output_message(management_dict[channel_id_str])
    edit_message(client,management_dict[channel_id_str]["output_channel"],management_dict[channel_id_str]["output_message"],content=output_message_content)

    save_management_dict(management_dict)
    create(client, Reaction, m, '👍')

end
