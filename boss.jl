mutable struct Boss
    name::String
    hp::Int
end


Boss_dict = Dict(
            "normal" => Dict(
                1 => Boss("ゴブリングレート",600),
                2 => Boss("ライライ",800),
                3 => Boss("ニードルクリーパー",1000),
                4 => Boss("サイクロプス",1200),
                5 => Boss("レサトパルト",1500)
            ),
            "very_hard" => Dict(
                1 => Boss("ゴブリングレート",700),
                2 => Boss("ライライ",900),
                3 => Boss("ニードルクリーパー",1200),
                4 => Boss("サイクロプス",1400),
                5 => Boss("レサトパルト",1700)
            )
)