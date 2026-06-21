//
//  MockData.swift
//  HuahuaDiary
//
//  Seed data ported from design_handoff_huahua_diary/data.js.
//  TODO (Phase 2): replace with persistence + server.
//

import Foundation

enum MockData {

    // MARK: - 6 plants ----------------------------------------------------------

    static let plants: [Plant] = [ciji, tuanzi, yuanyuan, alv, laobei, zhaozhao]

    static let ciji = Plant(
        id: "ciji", name: "小刺", species: "仙人掌", shape: .cactus, paletteKind: .cactus,
        tagsOn: ["傲娇", "冷漠", "嘴硬心软"],
        tagsOff: ["温柔", "话唠", "随和", "粘人", "怕冷", "爱晒太阳"],
        custom: "超级怕被淹，土干透了才肯喝水。",
        style: "嘴上傲娇冷漠、爱逞强，字里行间却藏着在乎和想念。常口是心非，偶尔用括号补一句真心话。",
        voice: "听说今天有雨啊……（小声）那你就别来浇水了，我，我还撑得住。",
        opener: "听说今天有雨啊……（小声）那你就别来浇水了，我，我还撑得住。别一天到晚惦记我。",
        days: 182, mood: "想它", stars: 5, status: "晒得正好", statusTone: .good,
        photoId: "p-ciji", born: "2025年12月7日",
        diary: cijiDiary,
        selfCare: SelfCare(
            say: "我是小刺。别看我一身刺，其实最省心——只要你别对我太「上心」。",
            tips: [
                CareTip(icon: .drop, label: "浇水", text: "土干透了再浇，别老来淹我……（渴的时候，我才不会喊呢。）"),
                CareTip(icon: .sun, label: "光照", text: "把我搁最晒的窗边，越晒我越精神。"),
                CareTip(icon: .heart, label: "我怕啥", text: "怕涝，更怕冷。冬天少浇点水，给我挪暖和些。")
            ]
        )
    )

    static let tuanzi = Plant(
        id: "tuanzi", name: "团子", species: "玉露 · 多肉", shape: .succulent, paletteKind: .succulentPink,
        tagsOn: ["软萌", "怕冷", "黏人"],
        tagsOff: ["独立", "高冷", "毒舌", "话痨", "乐天"],
        custom: "晶莹剔透的小肉肉，最怕冷也最爱撒娇。",
        style: "软糯撒娇，黏人怕冷，喜欢用叠词，动不动就想要主人陪。语气甜甜的、有点小委屈。",
        voice: "今天好冷呀……可以把我搬到有太阳的窗台吗？我想你多陪陪我嘛。",
        opener: "今天好冷呀……可以把我搬到有太阳的窗台吗？我想你多陪陪我嘛。",
        days: 96, mood: "撒娇", stars: 4, status: "有点冷", statusTone: .warn,
        photoId: "p-tuanzi", born: "2026年3月3日",
        diary: tuanziDiary,
        selfCare: SelfCare(
            say: "我是团子，软软的一小颗～照顾我要轻轻的哦，我会一直黏着你。",
            tips: [
                CareTip(icon: .drop, label: "浇水", text: "沿着盆边给我一点点水就好啦，我最怕喝太多。"),
                CareTip(icon: .sun, label: "光照", text: "给我明亮的散光，别让大太阳晒伤我嘛。"),
                CareTip(icon: .heart, label: "我怕啥", text: "我超怕冷，天一凉一定要把我搬进屋里呀。")
            ]
        )
    )

    static let yuanyuan = Plant(
        id: "yuanyuan", name: "圆圆", species: "玉露 · 多肉", shape: .succulent, paletteKind: .succulentGreen,
        tagsOn: ["安静", "慢热", "治愈"],
        tagsOff: ["话痨", "高冷", "毒舌", "黏人", "乐天"],
        custom: "圆滚滚一小颗，话不多，但安安静静陪着就很安心。",
        style: "安静慢热，话少，偶尔轻轻蹦一句温温的话，像个治愈系小透明。",
        voice: "……（小声）我在的。今天，也悄悄陪着你。",
        opener: "……（小声）我在的。今天，也悄悄陪着你。",
        days: 88, mood: "安静", stars: 5, status: "状态稳定", statusTone: .good,
        photoId: "p-tuanzi-2", born: "2026年3月12日",
        diary: yuanyuanDiary,
        selfCare: SelfCare(
            say: "我是圆圆，话不多……照顾我跟团子一样就好，安安静静的就行。",
            tips: [
                CareTip(icon: .drop, label: "浇水", text: "沿盆边给一点点水就好，我跟团子一样怕涝。"),
                CareTip(icon: .sun, label: "光照", text: "明亮的散光最舒服，别让我被正午暴晒。"),
                CareTip(icon: .heart, label: "我怕啥", text: "怕冷怕闷。天凉记得把我搬进屋，盆要透气。")
            ]
        )
    )

    static let alv = Plant(
        id: "alv", name: "阿绿", species: "绿萝", shape: .pothos, paletteKind: .pothos,
        tagsOn: ["话唠", "随和", "爱鼓励"],
        tagsOff: ["高冷", "傲娇", "怕冷", "毒舌", "安静"],
        custom: "皮实好养，没心没肺地乐观，一根藤能爬满整面墙。",
        style: "热情话唠，没心没肺地乐观，总在给主人加油打气，爱报喜（又长新叶啦）。语气元气满满。",
        voice: "嘿！今天也要加油哦～ 我又冒了一片新叶子，你快看你快看！",
        opener: "嘿！今天也要加油哦～ 我又冒了一片新叶子，你快看你快看！",
        days: 240, mood: "元气", stars: 5, status: "刚长新叶", statusTone: .good,
        photoId: "p-alv", born: "2025年10月10日",
        diary: alvDiary,
        selfCare: SelfCare(
            say: "嘿！我是阿绿，超好养的，养我你一定特有成就感——放轻松！",
            tips: [
                CareTip(icon: .drop, label: "浇水", text: "表土干了就给我浇透，大概五到七天一次，好记吧！"),
                CareTip(icon: .sun, label: "光照", text: "散光就够啦，别拿我直晒，我不挑的～"),
                CareTip(icon: .leaf, label: "小贴士", text: "常给我擦擦叶子我会更亮，藤长长了帮我牵一牵！")
            ]
        )
    )

    static let laobei = Plant(
        id: "laobei", name: "老背", species: "龟背竹", shape: .monstera, paletteKind: .monstera,
        tagsOn: ["话痨", "爱分析", "嘴毒靠谱"],
        tagsOff: ["温柔", "粘人", "软萌", "安静", "乐天"],
        custom: "叶子开了一身的裂口，像个看透一切的老法师。",
        style: "话痨爱分析，有点毒舌但句句靠谱，爱点评家里其它植物，自带长辈式吐槽。",
        voice: "你那盆多肉又浇多了吧？我观察很久了——叶子都发软了，下次手轻点。",
        opener: "你那盆多肉又浇多了吧？我观察很久了——叶子都发软了，下次手轻点。",
        days: 410, mood: "操心", stars: 4, status: "状态稳定", statusTone: .good,
        photoId: "p-laobei", born: "2025年4月20日",
        diary: laobeiDiary,
        selfCare: SelfCare(
            say: "我是老背。听好了——养我这点事，我门儿清，照做准没错。",
            tips: [
                CareTip(icon: .drop, label: "浇水", text: "表土干两厘米再浇，约七到十天一次，别手抖。"),
                CareTip(icon: .sun, label: "光照", text: "明亮散光最好，长时间暴晒我可不乐意。"),
                CareTip(icon: .leaf, label: "小贴士", text: "定期擦叶、立根支柱让我爬。叶子开裂是好事，别慌。")
            ]
        )
    )

    static let zhaozhao = Plant(
        id: "zhaozhao", name: "朝朝", species: "向日葵", shape: .sunflower, paletteKind: .sunflower,
        tagsOn: ["元气", "热情", "乐天"],
        tagsOff: ["高冷", "傲娇", "毒舌", "安静", "怕生"],
        custom: "一整天都追着太阳转，是家里的小太阳本阳。",
        style: "阳光热情、积极乐天，永远朝着光，鼓励主人别低头，语气明亮有力量。",
        voice: "太阳出来啦！我一整天都朝着光转，你也别老低着头呀，抬头看看嘛。",
        opener: "太阳出来啦！我一整天都朝着光转，你也别老低着头呀，抬头看看嘛。",
        days: 33, mood: "灿烂", stars: 5, status: "朝着太阳", statusTone: .good,
        photoId: "p-zhaozhao", born: "2026年5月5日",
        diary: zhaozhaoDiary,
        selfCare: SelfCare(
            say: "嗨！我是朝朝，朝着太阳的朝——想让我灿烂，其实超简单！",
            tips: [
                CareTip(icon: .drop, label: "浇水", text: "保持土壤微微湿润，两三天给我喝一次水。"),
                CareTip(icon: .sun, label: "光照", text: "光照越多越好，让我整天追着太阳转吧！"),
                CareTip(icon: .heart, label: "小贴士", text: "花期我胃口大，水和肥都要管够哦！")
            ]
        )
    )

    // MARK: - Diaries ----------------------------------------------------------

    static let cijiDiary: [DiaryEntry] = [
        DiaryEntry(
            id: "ciji-1", kind: .record, day: "今天", date: "6月7日",
            weather: "🌧 小雨 22°", mood: "想它", type: .talk, photo: "diary-ciji-1",
            quote: [
                .plain("今天有雨，小刺说不用浇水了，"),
                .highlight("还嘴硬说不想我"),
                .plain("，但我知道它"),
                .highlight("想了"),
                .plain("。")
            ],
            voice: "（小声）你别来了……我自己待着也挺好的。", stars: 5
        ),
        DiaryEntry(
            id: "ciji-2", kind: .record, day: "3 天前", date: "6月4日",
            weather: "☀️ 晴 28°", mood: "开心", type: .photo, photo: "diary-ciji-1",
            quote: [
                .plain("阳光好好，给它拍了张照。它说"),
                .highlight("晒得正舒服，别打扰"),
                .plain("。")
            ],
            voice: "哼，晒太阳呢，别吵。（其实……谢谢你记得我。）", stars: 4
        ),
        DiaryEntry(
            id: "ciji-3", kind: .record, day: "上周", date: "5月31日",
            weather: "⛅ 多云 25°", mood: "平静", type: .photo, photo: "diary-ciji-3",
            quote: [.plain("给它拍了张照，问它今天好不好看。")],
            voice: "……拍这么多干嘛，我本来就好看。（开心）", stars: 5
        ),
        DiaryEntry(
            id: "ciji-4", kind: .record, day: "认识第 1 天", date: "去年12月7日",
            weather: "❄️ 晴 8°", mood: "初遇", type: .born, photo: nil,
            quote: [
                .plain("第一次见面。它说它叫小刺，"),
                .highlight("傲娇但其实很开心认识我"),
                .plain("。")
            ],
            voice: "你好！第一次见面～ 我叫小刺，傲娇，但其实很开心认识你。", stars: 5
        )
    ]

    static let tuanziDiary: [DiaryEntry] = [
        DiaryEntry(
            id: "tz-1", kind: .record, day: "今天", date: "6月7日",
            weather: "🌧 小雨 22°", mood: "撒娇", type: .talk, photo: "diary-tz-1",
            quote: [
                .plain("把团子搬到了窗台，它说"),
                .highlight("这里暖暖的最喜欢"),
                .plain("。")
            ],
            voice: "谢谢你陪我嘛～ 这里暖暖的，最喜欢了。", stars: 5
        ),
        DiaryEntry(
            id: "tz-2", kind: .record, day: "5 天前", date: "6月2日",
            weather: "☀️ 晴 27°", mood: "开心", type: .talk, photo: nil,
            quote: [
                .plain("陪团子晒了会儿太阳，它"),
                .highlight("缩成软软一小团"),
                .plain("。")
            ],
            voice: "嗯嗯～ 刚刚好，谢谢你记得我。", stars: 4
        ),
        DiaryEntry(
            id: "tz-3", kind: .record, day: "认识第 1 天", date: "3月3日",
            weather: "⛅ 多云 18°", mood: "初遇", type: .born, photo: nil,
            quote: [.plain("第一次见面，软软的一小颗。")],
            voice: "你好呀～ 我叫团子，有点怕冷，要多陪陪我哦。", stars: 5
        )
    ]

    static let yuanyuanDiary: [DiaryEntry] = [
        DiaryEntry(
            id: "yy-1", kind: .record, day: "今天", date: "6月7日",
            weather: "🌧 小雨 22°", mood: "安静", type: .photo, photo: "p-tuanzi-2",
            quote: [
                .plain("给圆圆拍了张照，它"),
                .highlight("还是那么圆，那么安静"),
                .plain("。")
            ],
            voice: "……（小声）你来啦。", stars: 5
        ),
        DiaryEntry(
            id: "yy-2", kind: .record, day: "上周", date: "5月30日",
            weather: "⛅ 多云 24°", mood: "平静", type: .talk, photo: nil,
            quote: [.plain("静静陪圆圆坐了会儿。")],
            voice: "嗯……谢谢你，记得我。", stars: 5
        )
    ]

    static let alvDiary: [DiaryEntry] = [
        DiaryEntry(
            id: "al-1", kind: .record, day: "今天", date: "6月7日",
            weather: "🌧 小雨 22°", mood: "元气", type: .talk, photo: "diary-al-1",
            quote: [
                .plain("阿绿又冒新叶了，"),
                .highlight("开心得藤都翘起来"),
                .plain("。")
            ],
            voice: "你快看你快看！我又长了一片新叶子，厉害吧～", stars: 5
        ),
        DiaryEntry(
            id: "al-2", kind: .record, day: "2 天前", date: "6月5日",
            weather: "☀️ 晴 26°", mood: "开心", type: .talk, photo: nil,
            quote: [
                .plain("阿绿今天特别精神，"),
                .highlight("叶子绿得发亮"),
                .plain("。")
            ],
            voice: "你看我多精神！今天也要元气满满哦～", stars: 5
        ),
        DiaryEntry(
            id: "al-3", kind: .record, day: "认识第 1 天", date: "去年10月10日",
            weather: "☀️ 晴 20°", mood: "初遇", type: .born, photo: nil,
            quote: [.plain("第一次见面，一来就叽叽喳喳。")],
            voice: "嘿！我是阿绿，超好养的，我们会处得很开心的！", stars: 5
        )
    ]

    static let laobeiDiary: [DiaryEntry] = [
        DiaryEntry(
            id: "lb-1", kind: .record, day: "今天", date: "6月7日",
            weather: "🌧 小雨 22°", mood: "操心", type: .talk, photo: "diary-lb-1",
            quote: [
                .plain("老背又在点评全家的花，"),
                .highlight("嘴上嫌弃心里操心"),
                .plain("。")
            ],
            voice: "那盆多肉又浇多了吧？我观察很久了，下次手轻点。", stars: 4
        ),
        DiaryEntry(
            id: "lb-2", kind: .record, day: "6 天前", date: "6月1日",
            weather: "⛅ 多云 24°", mood: "平静", type: .talk, photo: nil,
            quote: [
                .plain("给它擦了擦叶子，"),
                .highlight("裂口越来越多了"),
                .plain("。")
            ],
            voice: "行吧，擦得还算干净。叶子开裂是好事，别大惊小怪。", stars: 4
        ),
        DiaryEntry(
            id: "lb-3", kind: .record, day: "认识第 1 天", date: "去年4月20日",
            weather: "☀️ 晴 19°", mood: "初遇", type: .born, photo: nil,
            quote: [.plain("第一次见面，一副看透一切的样子。")],
            voice: "新来的？我叫老背，这屋里的事我都门儿清。", stars: 4
        )
    ]

    static let zhaozhaoDiary: [DiaryEntry] = [
        DiaryEntry(
            id: "zz-1", kind: .record, day: "今天", date: "6月7日",
            weather: "🌧 小雨 22°", mood: "灿烂", type: .talk, photo: "diary-zz-1",
            quote: [
                .plain("朝朝一直追着光转，"),
                .highlight("叫我也别低头"),
                .plain("。")
            ],
            voice: "太阳出来啦！你也别老低着头呀，抬头看看嘛。", stars: 5
        ),
        DiaryEntry(
            id: "zz-2", kind: .record, day: "昨天", date: "6月6日",
            weather: "☀️ 晴 29°", mood: "开心", type: .talk, photo: nil,
            quote: [
                .plain("陪朝朝看了会儿夕阳，它"),
                .highlight("一直朝着光"),
                .plain("。")
            ],
            voice: "谢谢你！今天阳光真好，我要使劲长高高～", stars: 5
        ),
        DiaryEntry(
            id: "zz-3", kind: .record, day: "认识第 1 天", date: "5月5日",
            weather: "☀️ 晴 25°", mood: "初遇", type: .born, photo: nil,
            quote: [.plain("第一次见面，小小一株却很有劲。")],
            voice: "嗨！我是朝朝，朝着太阳的朝～ 一起向着光吧！", stars: 5
        )
    ]

    // MARK: - Clinic cases -----------------------------------------------------

    static let clinicCases: [ClinicCase] = [
        ClinicCase(
            id: "case-tz", plantId: "tuanzi", no: "No.014", date: "6月7日", seen: "今天",
            complaint: "叶片发软、底部叶子透明化",
            diagnosis: "轻度受冻 + 盆土偏湿，根部有积水风险",
            rx: "移到 18° 以上暖处，断水一周，沿盆边少量给水",
            status: .recovering, progress: 35,
            note: "刚接诊，已搬到窗台回暖。明天复查叶片硬度。",
            patientName: nil, patientSpecies: nil, cause: nil, lesson: nil
        ),
        ClinicCase(
            id: "case-al", plantId: "alv", no: "No.013", date: "5月28日", seen: "10 天前",
            complaint: "新叶发黄、叶尖焦边",
            diagnosis: "浇水过勤 + 强光直射灼伤",
            rx: "改 5–7 天浇一次，挪到散射光处，剪除焦叶",
            status: .healed, progress: 100,
            note: "已痊愈。新叶翠绿，藤又开始爬墙了。",
            patientName: nil, patientSpecies: nil, cause: nil, lesson: nil
        ),
        ClinicCase(
            id: "case-ciji", plantId: "ciji", no: "No.009", date: "5月10日", seen: "上月",
            complaint: "基部发软、颜色发暗",
            diagnosis: "出差期间被误浇两次，轻度积水",
            rx: "彻底断水三周，换疏松沙质土，多晒太阳",
            status: .healed, progress: 100,
            note: "已痊愈。又是那副傲娇挺拔的样子了。",
            patientName: nil, patientSpecies: nil, cause: nil, lesson: nil
        ),
        ClinicCase(
            id: "case-lb", plantId: "laobei", no: "No.006", date: "4月22日", seen: "复诊提醒",
            complaint: "气根杂乱、叶片开裂不均",
            diagnosis: "正常生长，但缺攀爬支撑",
            rx: "立水苔柱牵引气根，定期擦叶",
            status: .recheck, progress: 80,
            note: "基本恢复，建议两周后复查支柱牵引情况。",
            patientName: nil, patientSpecies: nil, cause: nil, lesson: nil
        ),
        ClinicCase(
            id: "case-mint", plantId: "laobei", no: "No.004", date: "3月15日", seen: "已送别",
            complaint: "整株蒂蕾发黑、性茎软倒",
            diagnosis: "长期积水烂根，送医太迟",
            rx: "已无法挽救",
            status: .dead, progress: 0,
            note: "安息。下一盆一定用透气的盆。",
            patientName: "薄荷", patientSpecies: "薄荷",
            cause: "泡在不透气的闷盆里，连续阴雨天还天天浇水，根系泡烂发黑。",
            lesson: "薄荷耐湿但怕涝。阴雨天、不透气的盆要扣减浇水，宁干勿湿；发现茎软要立刻脱盆查根。"
        ),
        ClinicCase(
            id: "case-luwei", plantId: "ciji", no: "No.002", date: "2月1日", seen: "已送别",
            complaint: "叶片冻伤透明、整盆化水塌陷",
            diagnosis: "阳台过冬被严霜冻伤，低温性冻死",
            rx: "已无法挽救",
            status: .dead, progress: 0,
            note: "安息。今冬提前设了降温提醒。",
            patientName: "芦荟", patientSpecies: "芦荟",
            cause: "冬天忘了搬进屋，夜里阳台降到 0° 以下，叶细胞被冻穿。",
            lesson: "多肉/不耐寒的花，气温低于 5° 就要移到室内；靠窗边夜间会更冷，别依赖白天的体感。"
        )
    ]

    // MARK: - 未知新植物（intake 看诊时用）

    static let unknownPlant = Plant(
        id: "unknown", name: "新朋友", species: "未知品种", shape: .succulent,
        paletteKind: .unknown,
        tagsOn: [], tagsOff: [],
        custom: "暂无", style: "初来乍到。",
        voice: "（小声）我…我来看病了。", opener: "（小声）我…我来看病了。",
        days: 1, mood: "初遇", stars: 5,
        status: "初诊中", statusTone: .warn,
        photoId: "intake-new", born: "今天",
        diary: [],
        selfCare: SelfCare(say: "先让花大夫看看吧。", tips: []),
        isNew: true
    )
}
