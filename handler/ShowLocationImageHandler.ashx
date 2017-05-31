<%@ WebHandler Language="C#" Class="ShowLocationImageHandler" %>

using System.IO;
using System.Xml;
using System.Net;
using System.Web;
using MarvalSoftware.UI.WebUI.ServiceDesk.RFP.Plugins;
using Newtonsoft.Json;


/// <summary>
/// Show Location Image Plugin Handler
/// </summary>
public class ShowLocationImageHandler : PluginHandler
{
    public override bool IsReusable { get { return false; } }

    private string mSMBaseUrl { get { return string.Format("{0}://{1}{2}{3}", HttpContext.Current.Request.Url.Scheme, HttpContext.Current.Request.Url.Host, HttpContext.Current.Request.Url.Port == 80 || HttpContext.Current.Request.Url.Port == 443 ? "" : string.Format(":{0}",HttpContext.Current.Request.Url.Port) , MarvalSoftware.UI.WebUI.ServiceDesk.WebHelper.ApplicationPath); } }
    private string mSMWSEAdr { get { return this.GlobalSettings["MSM WSE Address"]; } }
    private string mSMWSEEncUsr { get { return this.GlobalSettings["MSM WSE User Name"]; } }
    private string mSMWSEEncPwd { get { return this.GlobalSettings["MSM WSE Password"]; } }
    private string pluginLocationFieldSelector { get { return this.GlobalSettings["Location Element Selector Query"]; } }

    /// <summary>
    /// Main Request Handler
    /// </summary>
    public override void HandleRequest(HttpContext context)
    {
        switch (context.Request.HttpMethod)
        {
            case "GET":
                string locationId = context.Request.Params["LocationID"] ?? string.Empty;
                if (string.IsNullOrWhiteSpace(locationId)) context.Response.Write(JsonHelper.ToJSON(pluginLocationFieldSelector));
                else context.Response.Write(JsonHelper.ToJSON(getClosestLocationImageUrl(locationId)));
                break;
        }
    }

    /// <summary>
    /// Return Closest Location Image Url
    /// </summary>
    private string getClosestLocationImageUrl(string locId)
    {
        string imageViewerUrl = string.Empty;
        try
        {
            HttpWebRequest request = CreateWebRequest(this.mSMWSEAdr, "http://www.marvalbaltic.lt/MSM/WebServiceExtensions/GetLocations", CreateSoapEnvelope(this.mSMWSEEncUsr, this.mSMWSEEncPwd, locId));
            string response = ProcessRequest(request);
            if (string.IsNullOrEmpty(response)) return string.Empty;
            XmlDocument soapResponse = new XmlDocument();
            soapResponse.LoadXml(XmlHelper.EscapeEscapeChar(response));
            XmlNodeList nodes = soapResponse.GetElementsByTagName("MSMLocation");
            if (nodes.Count != 1) return string.Empty;
            string photoLocId = nodes[0]["PhotoLocationID"].InnerText;
            if (!string.IsNullOrEmpty(photoLocId)) imageViewerUrl = string.Format("{0}/RFP/Handlers/PhotoViewer.ashx?entityType=1&entityId={1}&imageid=0", this.mSMBaseUrl, photoLocId);
        }
        catch { }
        return imageViewerUrl;
    }

    //Generic Methods

    /// <summary>
    /// Creates web request SOAP envelope
    /// </summary>
    /// <param name="usr">WSE User name</param>
    /// <param name="pwd">WSE Password</param>
    /// <param name="locId">Location ID</param>
    /// <returns>The XmlDocument ready to be sent</returns>
    private static XmlDocument CreateSoapEnvelope(string usr, string pwd, string locId)
    {
        XmlDocument soapEnvelop = new XmlDocument();
        soapEnvelop.LoadXml(string.Format(
@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:web=""http://www.marvalbaltic.lt/MSM/WebServiceExtensions/"">
    <soapenv:Header xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" />
    <soapenv:Body>
    <web:GetLocations>
      <web:username>{0}</web:username>
      <web:password>{1}</web:password>
      <web:sessionKey></web:sessionKey>
      <web:extraFilter>id={2}|photo=true</web:extraFilter>
    </web:GetLocations>
  </soapenv:Body>
</soapenv:Envelope>"
, usr, pwd, locId));
        return soapEnvelop;
    }

    /// <summary>
    /// Builds a HttpWebRequest
    /// </summary>
    /// <param name="url">The url for request</param>
    /// <param name="body">The body for the request</param>
    /// <param name="method">The verb for the request</param>
    /// <returns>The HttpWebRequest ready to be processed</returns>
    private static HttpWebRequest CreateWebRequest(string url = null, string action = null, XmlDocument soapEnvelopeXml = null)
    {
        try
        {
            HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(url);
            webRequest.Headers.Add("SOAPAction", action);
            webRequest.ContentType = "text/xml;charset=UTF-8";
            webRequest.Accept = "text/xml";
            webRequest.Method = "POST";
            using (Stream stream = webRequest.GetRequestStream()) { soapEnvelopeXml.Save(stream); }
            return webRequest;
        }
        catch { }
        return null;
    }

    /// <summary>
    /// Proccess a HttpWebRequest
    /// </summary>
    /// <param name="request">The HttpWebRequest</param>
    /// <returns>Process Response</returns>
    private static string ProcessRequest(HttpWebRequest request)
    {
        try
        {
            if (request == null) return string.Empty;
            using (WebResponse response = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(response.GetResponseStream()))
                {
                    return rd.ReadToEnd();
                }
            }
        }
        catch { }
        return string.Empty;
    }

    /// <summary>
    /// JsonHelper Functions
    /// </summary>
    internal class JsonHelper
    {
        public static string ToJSON(object obj)
        {
            return JsonConvert.SerializeObject(obj);
        }
    }

    /// <summary>
    /// XmlHelper Functions
    /// </summary>
    internal class XmlHelper
    {
        public static string EscapeEscapeChar(string xmlString)
        {
            if (string.IsNullOrEmpty(xmlString)) return xmlString;
            return xmlString.Replace("\\\"", "\"");
        }
        public static string EscapeXML(string nonXmlString)
        {
            if (string.IsNullOrEmpty(nonXmlString)) return nonXmlString;
            return nonXmlString.Replace("'", "&apos;").Replace("\"", "&quot;").Replace(">", "&gt;").Replace("<", "&lt;").Replace("&", "&amp;");
        }
        public static string UnescapeXML(string xmlString)
        {
            if (string.IsNullOrEmpty(xmlString)) return xmlString;
            return xmlString.Replace("&apos;", "'").Replace("&quot;", "\"").Replace("&gt;", ">").Replace("&lt;", "<").Replace("&amp;", "&");
        }
    }
}