function FindProxyForURL(url, host) {
    if (dnsDomainIs(host, "api.groq.com") ||
        dnsDomainIs(host, ".api.groq.com") ||
        dnsDomainIs(host, "groq.com") ||
        dnsDomainIs(host, ".groq.com") ||
        dnsDomainIs(host, "console.groq.com") ||
        dnsDomainIs(host, ".console.groq.com") ||
        dnsDomainIs(host, ".gemini.google.com") ||
        dnsDomainIs(host, "gemini.google.com") ||
        dnsDomainIs(host, ".bard.google.com") ||
        dnsDomainIs(host, ".aistudio.google.com") ||
        dnsDomainIs(host, "openrouter.ai") ||
        dnsDomainIs(host, ".openrouter.ai") ||
        dnsDomainIs(host, "api.openrouter.ai") ||
        dnsDomainIs(host, ".api.openrouter.ai")) {
        return "SOCKS5 127.0.0.1:2339";
    }
    if (dnsDomainIs(host, ".youtube.com") ||
        dnsDomainIs(host, "youtube.com") ||
        dnsDomainIs(host, ".googlevideo.com") ||
        dnsDomainIs(host, ".ytimg.com") ||
        dnsDomainIs(host, ".youtu.be") ||
        dnsDomainIs(host, ".ggpht.com")) {
        return "SOCKS5 127.0.0.1:2338";
    }
    if (dnsDomainIs(host, ".tiktok.com") ||
        dnsDomainIs(host, "tiktok.com") ||
        dnsDomainIs(host, ".tiktokcdn.com") ||
        dnsDomainIs(host, ".tiktokcdn-us.com") ||
        dnsDomainIs(host, ".tiktokv.com") ||
        dnsDomainIs(host, ".musical.ly") ||
        dnsDomainIs(host, ".byteoversea.com") ||
        dnsDomainIs(host, ".ibytedtos.com") ||
        dnsDomainIs(host, ".muscdn.com") ||
        dnsDomainIs(host, ".tiktokmusic.app")) {
        return "SOCKS5 127.0.0.1:2340";
    }
    return "DIRECT";
}