using Discord
include("base.jl")

function adjust(client::Client,m::Message,hp::Int)
    global management_dict
    channel_id_str = string(m.channel_id)

    if !haskey(management_dict,channel_id_str)
        return reply(client,m,"初期設定が完了しておりません．`.set`コマンドにて初期設定を完了させてください")
    end

    if !haskey(management_dict[channel_id_str],"remain_attack_channel")
        return reply(client,m,"残凸把握板の登録が完了しておりません．`.set`コマンドにて初期設定を完了させてください")
    end

    if  !haskey(management_dict[channel_id_str],"output_channel")
        return reply(client,m,"bot出力板の登録が完了しておりません．`.set`コマンドにて初期設定を完了させてください")
    end

    if hp <= 0
        return reply(client,m,"ボスを変更する場合には`.start`コマンドを使用して下さい")
    end
    boss_number = string(management_dict[channel_id_str]["boss_number"])

    management_dict[channel_id_str]["reserve"][boss_number]["remain_hp"] = hp
    management_dict[channel_id_str]["reserve"][boss_number]["plan_remain_hp"] = calc_plan_remain_hp(management_dict[channel_id_str]["reserve"][boss_number])

    output_message_content = create_output_message(management_dict[channel_id_str])
    edit_message(client,management_dict[channel_id_str]["output_channel"],management_dict[channel_id_str]["output_message"],content=output_message_content)

    save_management_dict(management_dict)
    create(client, Reaction, m, '👍')

end
