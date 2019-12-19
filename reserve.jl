using Discord
include("base.jl")



function reserve(client::Client,m::Message,boss_number::Int,damage::Int;over=false,attack=false)
    global management_dict
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

    if  !haskey(management_dict[channel_id_str],"output_message")
        return reply(client,m,"先に`.battle`コマンドを使用して下さい")
    end

    if !over
        #.attackコマンドを使用した場合
        if attack
            nothing
        elseif management_dict[channel_id_str]["reserve"][string(boss_number)]["plan_remain_hp"] == 0
            if boss_number == management_dict[channel_id_str]["boss_number"]
                return reply(client,m,"予約を無視して戦闘を行う場合には`.attack [予定ダメージ]`を送信して下さい")
            else
                return reply(client,m,"既に予約が一杯です")
            end
        end
    end




    reserve_dict = Dict(
        "name" =>  get_display_name(m),
        "id" => m.author.id,
        "damage" => damage,
        "attack" => attack,
        "over" => over
    )

    if attack
        push!(management_dict[channel_id_str]["reserve"][string(management_dict[channel_id_str]["boss_number"])]["reserve_list"],reserve_dict)
    else
        push!(management_dict[channel_id_str]["reserve"][string(boss_number)]["reserve_list"],reserve_dict)
    end

    management_dict[channel_id_str]["reserve"][string(boss_number)]["plan_remain_hp"] = calc_plan_remain_hp(management_dict[channel_id_str]["reserve"][string(boss_number)])
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
