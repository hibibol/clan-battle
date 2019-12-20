using  Discord
include("boss.jl")
include("base.jl")





function initialize_reserve_dict(channel_dict)

    channel_dict["reserve"] = Dict()

    for i=0:4
        lap = channel_dict["lap"] + div((channel_dict["boss_number"]+i),6)
        boss_number = (channel_dict["boss_number"]+i)%5
        if boss_number == 0
            boss_number = 5
        end
        boss_number_str = string(boss_number)#JSONに保存するためにキーを文字列にする必要あり．(BSONは良く分からん...)
        channel_dict["reserve"][boss_number_str] = Dict(
            "reserve_list" => [],
            "plan_remain_hp" => get_default_hp(lap,boss_number),
            "remain_hp" => get_default_hp(lap,boss_number)
        )

    end

    channel_dict["remain_attack"] = initiate_remain_attack_dict(c,channel_dict)
    dt_now =now(tz"Asia/Tokyo") - Hour(5)
    channel_dict["today"] ="$(month(dt_now))月$(day(dt_now))日"

    return channel_dict
end





function battle(client::Client,m::Discord.Message;lap=1,boss_number=1)
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

    management_dict[channel_id_str]["lap"] = lap #周回数
    management_dict[channel_id_str]["boss_number"] = boss_number #現在のボスの番号


    management_dict[channel_id_str] = initialize_reserve_dict(management_dict[channel_id_str])

    #予約確認板に出力
    message_content = create_output_message(management_dict[channel_id_str])
    output_channel = get_channel(client,management_dict[channel_id_str]["output_channel"])
    output_message = fetch(create_message(client,management_dict[channel_id_str]["output_channel"],content=message_content))
    if output_message.ok
        management_dict[channel_id_str]["output_message"] = output_message.val.id
    else
        return reply(client,m,"予約確認板に出力出来ませんでした．設定を再度確認して下さい")
    end


    #残凸把握版に出力
    remain_attack_message_content = make_remain_attack_message_content(management_dict[channel_id_str]["remain_attack"],management_dict[channel_id_str]["today"])
    remain_attack_message = fetch(create_message(client,management_dict[channel_id_str]["remain_attack_channel"],content=remain_attack_message_content))
    if remain_attack_message.ok
        management_dict[channel_id_str]["remain_attack_message"] = remain_attack_message.val.id
    else
        return reply(client,m,"残凸把握板に出力出来ませんでした．設定を再度確認して下さい")
    end
    save_management_dict(management_dict)
    create(client, Reaction, m, '👍')

end
