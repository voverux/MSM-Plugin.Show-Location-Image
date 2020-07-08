<%@ WebHandler Language="C#" Class="ShowLocationImageHandler" %>
using System;
using System.IO;
using System.Xml;
using System.Net;
using System.Web;
using System.Linq;
using Newtonsoft.Json;
using MarvalSoftware.Data.ServiceDesk;
using MarvalSoftware.UI.WebUI.ServiceDesk.RFP.Plugins;

/// <summary>
/// Show Location Image Plugin Handler
/// </summary>
public class ShowLocationImageHandler : PluginHandler
{
    public override bool IsReusable { get { return false; } }

    private string mSMBaseUrl { get { return string.Format("{0}://{1}{2}{3}", HttpContext.Current.Request.Url.Scheme, HttpContext.Current.Request.Url.Host, HttpContext.Current.Request.Url.Port == 80 || HttpContext.Current.Request.Url.Port == 443 ? "" : string.Format(":{0}",HttpContext.Current.Request.Url.Port) , MarvalSoftware.UI.WebUI.ServiceDesk.WebHelper.ApplicationPath); } }

    /// <summary>
    /// Main Request Handler
    /// </summary>
    public override void HandleRequest(HttpContext context)
    {
        switch (context.Request.HttpMethod)
        {
            case "GET":
				int locationId = Int32.TryParse(context.Request.Params["LocationID"] ?? string.Empty, out locationId) ? locationId : 0;
                if (locationId > 0) 
					context.Response.Write(getClosestLocationImageUrl(locationId));
                else
					context.Response.Write(string.Empty);
                break;
        }
    }

    /// <summary>
    /// Return Closest Location Image Url
    /// </summary>
    private string getClosestLocationImageUrl(int locationId)
    {
        string imageViewerUrl = string.Empty;
        try
        {
			var broker = new LocationBroker();
			var locations = broker.GetFullLocationDetails(locationId);
			foreach(int locId in locations.Select(x => x.Identifier).Reverse().ToList())
			{
				if(broker.CheckForLocationPhoto(locId))
				{
					imageViewerUrl = string.Format("{0}/RFP/Handlers/PhotoViewer.ashx?entityType=1&entityId={1}&imageid=0", this.mSMBaseUrl, locId);
					break;
				}
			}
        }
        catch { }
        return imageViewerUrl;
    }
}