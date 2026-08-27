function FindProxyForURL(url, host) {
    if (dnsDomainIs(host, ".gemini.google.com") ||
        dnsDomainIs(host, "gemini.google.com") ||
        dnsDomainIs(host, ".bard.google.com") ||
        dnsDomainIs(host, ".aistudio.google.com")) {
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
    return "DIRECT";
}