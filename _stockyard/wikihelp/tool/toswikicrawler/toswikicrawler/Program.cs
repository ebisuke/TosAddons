using System;
using System.Collections.Generic;
using System.Drawing.Imaging;
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
        private static readonly string _imgbasepath = "https://cdn.wikiwiki.jp/to/w/tosjp/";
        private static readonly string _startpage = "MenuBar";
        private static Dictionary<string,string> _acquiredPage = new Dictionary<string, string>();
        private static List<string> _remainPage=new List<string>();
        private static List<(string,string)> _remainImages = new List<(string, string)>();
        private static List<(string, string)> _acquiredImages = new List<(string, string)>();

        static void Main(string[] args)
        {
            _remainPage.Add(_startpage);
            int limit = 99999;
            while (_remainPage.Count > 0 && limit>0)
            {
                var page = _remainPage[0];
                _remainPage.Remove(page);
                Crawl(page);
                Thread.Sleep(500);
                limit--;
            }
            while (_remainImages.Count > 0 )
            {
                var image = _remainImages[0];
                _remainImages.Remove(image);
                AcquireImages(image.Item1, image.Item2);
                Thread.Sleep(500);
            }
            GenerateLuaCode();
            GenerateSkinSetCode();
        }

        static void AcquireImages(string page,string imagename)
        {
            Console.WriteLine(page+"/"+imagename);
            string path;
            HttpWebRequest req;
            if (imagename.StartsWith("http"))
            {
                req = HttpWebRequest.CreateHttp(imagename);
                path = imagename;

            }
            else
            {
                path = imagename;
                if (imagename.StartsWith("./")|| !imagename.Contains("/"))
                {
                    req = HttpWebRequest.CreateHttp(_imgbasepath + page + "/::ref/" + path);
                }
                else
                {
                    Regex r=new Regex("(.*)/(.*?)$");
                    Match m = r.Match(imagename);
                    req = HttpWebRequest.CreateHttp(_imgbasepath + m.Groups[1] + "/::ref/" + m.Groups[2]);
                }
            }

            path = path.Replace("./", "").Replace(":", "_").Replace("/", "_");
            path = path.Replace("\\.","").Replace("(", "_").Replace(")", "_");
            Directory.CreateDirectory("ui.ipf\\skin");
            try
            {
                var resp = req.GetResponse();
                string data;
                string filename = "ui.ipf\\skin\\" + (path).Replace("/", "_");
                using (FileStream fs = new FileStream(filename, FileMode.Create))
                {
                    byte[] mem = new byte[65536];
                    for (; ; )
                    {
                        //データを読み込む
                        int readSize = resp.GetResponseStream().Read(mem, 0, mem.Length);
                        if (readSize == 0)
                        {
                            //すべてのデータを読み込んだ時
                            break;
                        }
                        //読み込んだデータをファイルに書き込む
                        fs.Write(mem, 0, readSize);
                    }
                    
                    _acquiredImages.Add((path, filename));
                }
            }catch(Exception exp)

            {
                Console.Write(" FAIL:"+exp.Message);
            }
        }
        static void GenerateSkinSetCode()
        {
            Directory.CreateDirectory("ui.ipf\\baseskinset\\");
            using (var fs = new FileStream("ui.ipf\\baseskinset\\toswiki.xml", FileMode.Create))
            using (var sw = new StreamWriter(fs))
            {
                sw.WriteLine("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
                sw.WriteLine("<skinset name=\"Base\">");
                sw.WriteLine(" <imagelist category=\"wikihelp\">");
                
                foreach (var img in _acquiredImages)
                {
                    var li = System.Drawing.Image.FromFile(img.Item2);
                    string imgname = img.Item1;
                    if (Path.GetExtension(img.Item2) == ".gif")
                    {
                        li.Save(img.Item2.Substring(0,img.Item2.Length-4)+".png",ImageFormat.Png);
                        imgname = img.Item1.Substring(0, img.Item1.Length - 4) + ".png";

                    }
                    sw.WriteLine("<image name=\""+ imgname + "\" file=\"\\skin\\"+ imgname + $"\" imgrect=\"0 0 {li.Width} {li.Height}\"/>");
                }
                sw.WriteLine("</imagelist>");
                sw.WriteLine("</skinset>");

            }

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
            try { 
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
                string idt = result.Groups[1].Value.Replace("&gt;", ">").Replace("&lt;", "<").Replace("&amp;", "&");
                //解析
                _acquiredPage[name] = idt;
                Regex rega = new Regex(@"\[\[(.*?)\]\]");
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
                        if (!pagename.Contains("#"))
                        {
                            if (!_remainPage.Contains(pagename) && !_acquiredPage.ContainsKey(pagename))
                            {

                                _remainPage.Add(pagename);

                            }
                        }
                    }
                }

                Regex imagematcher = new Regex(@"(#ref|&attachref)\((.*?)(,|\);)");
                var imgs = imagematcher.Matches(idt);
                foreach (Match img in imgs)
                {
                    var imgname = img.Groups[2].Value;
                    var tup = (name, imgname);
                    if (!_remainImages.Any(x=>x.Item1==tup.name && x.Item2==tup.imgname))
                    {
                        _remainImages.Add(tup);
                    }
                }
            }
            }
            catch (WebException exp)

            {
                Console.Write(" FAIL:" + exp.Message);
            }
        }
    }
}
