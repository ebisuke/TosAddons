using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;

namespace toswikicrawler
{
    class Program
    {
        private static readonly string _basepath = "https://wikiwiki.jp/tosjp/?cmd=edit&page=";
        private static readonly string _startpage = "MenuBar";
        private static Dictionary<string,string> _acquiredPage = new Dictionary<string, string>();
        private static List<string> _remainPage=new List<string>();
        private static List<string> _remainImages = new List<string>();

        static void Main(string[] args)
        {
            _remainPage.Add(_startpage);
            int limit = 5;
            while (_remainPage.Count > 0 && limit>0)
            {
                var page = _remainPage[0];
                _remainPage.Remove(page);
                Crawl(page);
                Thread.Sleep(500);
                limit--;
            }

            GenerateLuaCode();
        }

        static void GenerateLuaCode()
        {
            Directory.CreateDirectory("addon_d.ipf\\wikihelp");
            using(var fs=new FileStream("addon_d.ipf\\wikihelp\\toswiki.lua", FileMode.Create))
            using (var sw = new StreamWriter(fs))
            {
                sw.WriteLine("WIKIHELP_PAGES={");

                foreach (var acq in _acquiredPage)
                {
                    sw.WriteLine($"[\"{acq.Key}\"]=[==["+acq.Value+"]==],");
                }
                sw.WriteLine("}");

            }

        }
        static void Crawl(string name)
        {
            Console.WriteLine(name);
            HttpWebRequest req = HttpWebRequest.CreateHttp(_basepath+name);
            var resp=req.GetResponse();
            string data;
            using(StreamReader sr = new StreamReader(resp.GetResponseStream()))
            {
                data=sr.ReadToEnd();
            }
            Regex reg=new Regex("<textarea name=\"msg\" rows=\"26\" cols=\"100\">(.*?)</textarea>",RegexOptions.Singleline);
            var result = reg.Match(data);
            if (result.Success == false)
            {
                return;
            }
            else
            {
                string idt = result.Groups[1].Value.Replace("&gt;",">").Replace("&lt;","<").Replace("&amp;", "&");
                //解析
                _acquiredPage[name] = idt;
                Regex rega = new Regex(@"\[\[(.*)\]\]");
                Regex reglink = new Regex(@">(.*)");
                Regex regign = new Regex(@"\:(.*)");
                var matches = rega.Matches(idt);
                foreach (Match match in matches)
                {
                    Match link = reglink.Match(match.Groups[1].Value);
                    Match ign = regign.Match(match.Groups[1].Value);
                    string pagename;
                    if (link.Success)
                    {
                        pagename = link.Groups[1].Value;
                    }
                    else
                    {
                        pagename = match.Groups[1].Value;
                    }

                    if (!ign.Success)
                    {
                        if (!_acquiredPage.ContainsKey(pagename))
                        {
                            _remainPage.Add(pagename);
                        }
                    }
                }
            }
        }
    }
}
