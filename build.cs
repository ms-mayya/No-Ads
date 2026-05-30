#!/usr/bin/env -S dotnet --
#:package SharpYaml@3.7.1
#:property PublishAot=false
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using SharpYaml;

// ── parse rules.yaml ─────────────────────────────────────────────────────────

const string SRC = "rules.yaml";
if (!File.Exists(SRC)) { Console.Error.WriteLine($"Not found: {SRC}"); return 1; }

var opts = new YamlSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
var doc = YamlSerializer.Deserialize<RulesDoc>(File.ReadAllText(SRC), opts)
           ?? throw new InvalidOperationException("Failed to parse rules.yaml");

var name = doc.Meta.Name;
var desc = doc.Meta.Desc;
var notes = doc.Meta.Notes;
var hostname = doc.Meta.Mitm.Hostname;

var validTypes = new HashSet<string>(StringComparer.Ordinal)
{
    "DOMAIN-SUFFIX", "DOMAIN-KEYWORD", "URL-REGEX", "DOMAIN-REGEX",
    "IP-CIDR", "IP-CIDR6", "PROCESS-NAME"
};

var rules = new List<(string Type, string Value, string Action)>();
foreach (var item in doc.Rules)
{
    if (item is null) continue;
    var parts = item.Split(',', 3);
    if (parts.Length == 3 && validTypes.Contains(parts[0]))
        rules.Add((parts[0], parts[1], parts[2]));
}

// ── generators ──────────────────────────────────────────────────────────────

string ClashDomainSet(string action)
{
    var sb = new StringBuilder("payload:\n");
    bool any = false;
    foreach (var (type, value, act) in rules)
        if (type == "DOMAIN-SUFFIX" && act == action)
        { sb.AppendLine($"  - '+.{value}'"); any = true; }
    if (!any) sb.AppendLine("  []");
    return sb.ToString();
}

string ClashClassical()
{
    var sb = new StringBuilder("payload:\n");
    bool any = false;
    foreach (var (type, value, act) in rules)
        if (type == "PROCESS-NAME")
        { sb.AppendLine($"  - PROCESS-NAME,{value},{act}"); any = true; }
    if (!any) sb.AppendLine("  []");
    return sb.ToString();
}

string Shadowrocket()
{
    var srTypes = new HashSet<string>(StringComparer.Ordinal)
    {
        "DOMAIN-SUFFIX", "DOMAIN-KEYWORD", "URL-REGEX", "DOMAIN-REGEX",
        "IP-CIDR", "IP-CIDR6"
    };
    var sb = new StringBuilder();
    sb.AppendLine($"#!name={name}");
    sb.AppendLine($"#!desc={desc}");
    sb.AppendLine($"#!notes={notes}");
    sb.AppendLine();
    sb.AppendLine("[MITM]");
    sb.AppendLine($"hostname = %APPEND%, {hostname}");
    sb.AppendLine();
    sb.AppendLine("[Rule]");
    foreach (var (type, value, act) in rules)
        if (srTypes.Contains(type))
            sb.AppendLine($"{type},{value},{act}");
    return sb.ToString();
}

string QX()
{
    var sb = new StringBuilder();
    sb.AppendLine($"#!name={name}");
    sb.AppendLine($"#!desc={desc}");
    sb.AppendLine();
    sb.AppendLine("[rewrite_local]");
    foreach (var (type, value, act) in rules)
        if (type == "URL-REGEX")
        {
            var qxAct = act == "REJECT" ? "reject" : act.ToLower();
            sb.AppendLine($"{value} url {qxAct}");
        }
    sb.AppendLine();
    sb.AppendLine("[mitm]");
    sb.AppendLine($"hostname = {hostname}");
    return sb.ToString();
}

string OpenClash()
{
    var sb = new StringBuilder();
    sb.AppendLine("[YAML]");
    sb.AppendLine("+rules:");
    foreach (var (type, value, act) in rules)
        if (type is "DOMAIN-SUFFIX" or "DOMAIN-KEYWORD" or "PROCESS-NAME")
            sb.AppendLine($"  - {type},{value},{act}");
    sb.AppendLine("""
    +proxy-groups:
      - name: PROXY
        type: select
        proxies:
          - 🔰 节点选择
    """);
    return sb.ToString();
}

string SingBox(string action)
{
    var selected = rules.Where(r => r.Action == action).ToList();
    var rulesArr = new JsonArray();

    void AddRule(string key, IEnumerable<string> values)
    {
        var distinct = values
            .Where(v => !string.IsNullOrWhiteSpace(v))
            .Distinct(StringComparer.Ordinal)
            .OrderBy(v => v, StringComparer.Ordinal)
            .ToList();

        if (distinct.Count == 0) return;

        var arr = new JsonArray();
        foreach (var value in distinct)
            arr.Add(value);

        rulesArr.Add(new JsonObject
        {
            [key] = arr
        });
    }

    AddRule("domain_suffix", selected.Where(r => r.Type == "DOMAIN-SUFFIX").Select(r => r.Value));
    AddRule("domain_keyword", selected.Where(r => r.Type == "DOMAIN-KEYWORD").Select(r => r.Value));
    AddRule("domain_regex", selected.Where(r => r.Type == "DOMAIN-REGEX").Select(r => r.Value));
    AddRule("ip_cidr", selected.Where(r => r.Type is "IP-CIDR" or "IP-CIDR6").Select(r => r.Value));
    AddRule("process_name", selected.Where(r => r.Type == "PROCESS-NAME").Select(r => r.Value));

    var root = new JsonObject
    {
        ["version"] = 5,
        ["rules"] = rulesArr
    };

    return root.ToJsonString(new JsonSerializerOptions { WriteIndented = true });
}

// ── write outputs ───────────────────────────────────────────────────────────

var dist = "dist";
var clashDir = Path.Combine(dist, "clash");
var singBoxDir = Path.Combine(dist, "sing-box");
Directory.CreateDirectory(clashDir);
Directory.CreateDirectory(singBoxDir);

var oc = OpenClash();
var outputs = new Dictionary<string, string>
{
    [Path.Combine(clashDir, "reject.yaml")] = ClashDomainSet("REJECT"),
    [Path.Combine(clashDir, "direct.yaml")] = ClashDomainSet("DIRECT"),
    [Path.Combine(clashDir, "proxy.yaml")] = ClashDomainSet("PROXY"),
    [Path.Combine(clashDir, "classical.yaml")] = ClashClassical(),
    [Path.Combine(dist, "sr_ad.module")] = Shadowrocket(),
    [Path.Combine(dist, "QX.conf")] = QX(),
    [Path.Combine(dist, "OpenClash.txt")] = oc,
    ["OpenClash.txt"] = oc,
    [Path.Combine(singBoxDir, "reject.json")] = SingBox("REJECT"),
    [Path.Combine(singBoxDir, "direct.json")] = SingBox("DIRECT"),
    [Path.Combine(singBoxDir, "proxy.json")] = SingBox("PROXY"),
};

foreach (var (path, content) in outputs)
{
    File.WriteAllText(path, content);
    Console.WriteLine($"  wrote {path}");
}
Console.WriteLine("build complete.");
return 0;

// ── model ───────────────────────────────────────────────────────────────────

record MitmConfig(string Hostname);
record MetaConfig(string Name, string Desc, string Notes, MitmConfig Mitm);
record RulesDoc(MetaConfig Meta, List<string?> Rules);
