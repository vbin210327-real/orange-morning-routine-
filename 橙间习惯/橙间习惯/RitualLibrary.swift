import Foundation

struct RitualPrompt: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let guidance: String
    let placeholder: String
}

enum RitualLibrary {
    static let prompts: [RitualPrompt] = [
        RitualPrompt(
            id: "proud",
            title: "昨日我最自豪的瞬间",
            guidance: "抓住一个让你嘴角上扬的小片刻，具体到细节。",
            placeholder: "例如：在会议上鼓起勇气表达观点，收获了真诚的认可。"
        ),
        RitualPrompt(
            id: "expectation",
            title: "今天我最期待的事情",
            guidance: "让期待成为行程中的小糖果，描述它的模样与感受。",
            placeholder: "例如：与老友约的午餐，预感到轻松与欢笑。"
        ),
        RitualPrompt(
            id: "joy",
            title: "思考今天可以为自己带来快乐的小事",
            guidance: "想象一件可立即执行的小行动，让它成为今日的快乐引爆点。",
            placeholder: "例如：午后散步去买一杯喜欢的拿铁，或是写下三句鼓励自己的话。"
        ),
        RitualPrompt(
            id: "gratitude",
            title: "此刻我感恩的两件小事",
            guidance: "感恩让心底点燈，写下具体的人或事及其带来的温度。",
            placeholder: "例如：窗外柔和的阳光，以及陪伴我成长的家人。"
        ),
        RitualPrompt(
            id: "self-love",
            title: "我喜爱自己的三个面向",
            guidance: "从细微处看见自我光芒，让喜欢成为今日的底色。",
            placeholder: "例如：我坚持阅读的习惯、温柔倾听朋友的能力、规律的睡眠。"
        )
    ]
}
