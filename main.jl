using Discord
include("token.jl")
include("set.jl")
include("battle.jl")
include("reserve.jl")
include("attack.jl")
include("fin.jl")
include("la.jl")
include("adjust.jl")

# Create a client.
c = Client(TOKEN,prefix=".")

function set_command(c::Client,m::Message,argument)

    if m.author.bot === true
        return
    end
    #@show m.author.bot

    new_argument = argument
    #全角スペース，全角数字に対応
    replace_pair = ["　" => " ",
                    "０" => "0",
                    "１" => "1",
                    "２" => "2",
                    "３" => "3",
                    "４" => "4",
                    "５" => "5",
                    "６" => "6",
                    "７" => "7",
                    "８" => "8",
                    "９" => "9",
                    "．" => ".",
                    "万" => ""
                    ]
    for pair in replace_pair
        new_argument = replace(new_argument,pair)
    end

    argument_list = split(new_argument," ",keepempty=false)

    if argument_list[1] == ".set" && length(argument_list) == 3
        return set_channel_id(c,m,argument_list[2],argument_list[3])

    elseif argument_list[1] == ".start" || argument_list[1] == ".開始"
        @show now(),m.author.username,new_argument
        if length(argument_list) == 1
            return battle(c,m)
        elseif length(argument_list) == 3
            if isdecimal(argument_list[2]) && isdecimal(argument_list[3])
                return battle(c,m,lap=int(argument_list[2]),boss_number=int(argument_list[3]))
            end
        end

    elseif argument_list[1] == ".reserve" || argument_list[1] == ".予約"
        @show now(),m.author.username,new_argument
        if length(argument_list) == 3
            if isdecimal(argument_list[2]) && isdecimal(argument_list[3])
                return reserve(c,m,int(argument_list[2]),int(argument_list[3]))
            end
        elseif length(argument_list) == 4
            if isdecimal(argument_list[2]) && isdecimal(argument_list[3]) && (argument_list[4] == "over" || argument_list[4] == "持ち越し")
                return reserve(c,m,int(argument_list[2]),int(argument_list[3]),over=true)
            end
        end

    elseif argument_list[1] == ".attack" ||  argument_list[1] == ".凸" 
        @show now(),m.author.username,new_argument
        if length(argument_list) == 1
            return attack(c,m)
        elseif length(argument_list) ==2
            if isdecimal(argument_list[2])
                #boss_numberは適当に入れてるだけのクソ実装，現在のボスに凸する場合
                return reserve(c,m,1,int(argument_list[2]),attack=true)
            end
        elseif length(argument_list) == 3
            if isdecimal(argument_list[2]) &&  (argument_list[3] == "over" || argument_list[3] == "持ち越し") 
                return reserve(c,m,1,int(argument_list[2]),over=true,attack=true) #持ち越しで現在のボスに凸する場合
            end
        end
    elseif argument_list[1] == ".fin" || argument_list[1] == ".完了"
        @show now(),m.author.username,new_argument
        if length(argument_list) == 2
            if isdecimal(argument_list[2])
                return fin(c,m,int(argument_list[2]))
            end
        end

    elseif argument_list[1] == ".la" || argument_list[1] == ".討伐" 
        @show now(),m.author.username,new_argument
        if length(argument_list) == 1
            return  la(c,m)
        elseif length(argument_list) == 2
            return  la(c,m,over_time = argument_list[2])
        end

    elseif argument_list[1] == ".adjust" || argument_list[1] == ".調整"
        @show now(),m.author.username,new_argument
        if length(argument_list) == 2
            if isdecimal(argument_list[2])
                return adjust(c,m,int(argument_list[2]))
            end
        end
    end


end



add_handler!(
    c,MessageCreate, (c,e) -> set_command(c,e.message,e.message.content)
)

# Log in to the Discord gateway.
open(c)
# Wait for the client to disconnect.
wait(c)
