using BingGeocoder;
using Microsoft.ApplicationInsights;
using Microsoft.ServiceBus;
using Microsoft.ServiceBus.Messaging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NYCJobsWeb.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using Microsoft.Azure.Search.Models;
using System.Net.Http;

namespace NYCJobsWeb.Controllers
{
    public class HomeController : Controller
    {

        private TelemetryClient telemetry = new TelemetryClient();
        public HomeController()
        {
        }

        // GET: Home
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult JobDetails()
        {
            return View();
        }

        public async Task<ActionResult> Search(string q = "", string businessTitleFacet = "", string postingTypeFacet = "", string salaryRangeFacet = "",
            string sortType = "", double lat = 40.736224, double lon = -73.99251, int currentPage = 0, int zipCode = 10001,
            int maxDistance = 0)
        {
            try
            {
                telemetry.TrackEvent("Search called");

                // Set up some properties:
                var properties = new Dictionary<string, string>
                    {   { "Query", q },
                        { "Sort type", sortType},
                        { "Max distance", Convert.ToString(maxDistance)}
                    };

                telemetry.TrackTrace("Search called", properties);

            // If blank search, assume they want to search everything
            if (string.IsNullOrWhiteSpace(q))
                    q = "*";

                string maxDistanceLat = string.Empty;
                string maxDistanceLon = string.Empty;

                //Do a search of the zip code index to get lat / long of this location
                //Eventually this should be extended to search beyond just zip (i.e. city)
                if (maxDistance > 0)
                {
                  using (var client = new HttpClient()) {
                    client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", ConfigurationManager.AppSettings["Ocp-Apim-Subscription-Key"]);
                    var uri = string.Format("{0}/api/jobs/searchzip?zipCode={1}", ConfigurationManager.AppSettings["NYCJobsApi"], zipCode.ToString());
                    var response = client.GetStringAsync(uri).Result;
                    var jobj = JObject.Parse(response);
                    var results = JsonConvert.DeserializeObject<IList<SearchResult>>(jobj.SelectToken("Results").ToString());
                      foreach (var result in results)
                      {
                          var doc = (dynamic)result.Document;
                          maxDistanceLat = Convert.ToString(doc["geo_location"].Latitude, CultureInfo.InvariantCulture);
                          maxDistanceLon = Convert.ToString(doc["geo_location"].Longitude, CultureInfo.InvariantCulture);
                          await Task.Delay(100);
                      }
                  }
                }

                

              using (var client = new HttpClient())
              {
                client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", ConfigurationManager.AppSettings["Ocp-Apim-Subscription-Key"]);
                var uri = string.Format("{11}/api/jobs/search?searchText={0}&businessTitleFacet={1}&postingTypeFacet={2}&salaryRangeFacet={3}&sortType={4}&lat={5}&lon={6}&currentPage={7}&maxDistance={8}&maxDistanceLat={9}&maxDistanceLon={10}",
                  q,businessTitleFacet,postingTypeFacet,salaryRangeFacet,sortType,lat, lon, currentPage,maxDistance, maxDistanceLat, maxDistanceLon, ConfigurationManager.AppSettings["NYCJobsApi"]);
                
                var response = client.GetStringAsync(uri).Result;
                var jobj = JObject.Parse(response);

                var count = jobj.SelectToken("Count").Value<string>();
                var facets = JsonConvert.DeserializeObject<FacetResults>(jobj.SelectToken("Facets").ToString());
                var results = JsonConvert.DeserializeObject<IList<SearchResult>>(jobj.SelectToken("Results").ToString());

                return new JsonResult
                {
                  // ***************************************************************************************************************************
                  // If you get an error here, make sure to check that you updated the SearchServiceName and SearchServiceApiKey in Web.config
                  // ***************************************************************************************************************************

                  JsonRequestBehavior = JsonRequestBehavior.AllowGet,
                  Data = new NYCJob() { Results = results, Facets = facets, Count = Convert.ToInt32(count) }
                };
              }
            }
            // app insight
            catch (Exception ex)
            {

                // Set up some properties:
                var properties = new Dictionary<string, string>
                    {   { "Query", q },
                        { "Sort type", sortType},
                        { "Max distance", Convert.ToString(maxDistance)}
                    };

                // Send the exception telemetry:
                telemetry.TrackException(ex, properties);
                throw ex;
            }
        }

        [HttpGet]
        public async Task<ActionResult> Suggest(string term, bool fuzzy = true)
        {
            try
            {
                telemetry.TrackEvent("Suggest called");

                // Set up some properties:
                var properties = new Dictionary<string, string>
                    {   { "Term", term },
                        { "IsFuzzy", Convert.ToString(fuzzy)}
                    };
                telemetry.TrackTrace("Suggest called", properties);

                // Call suggest query and return results
       
                DocumentSuggestResult suggresult;
                using (var client = new HttpClient()) {
                  client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", ConfigurationManager.AppSettings["Ocp-Apim-Subscription-Key"]);
                  var uri = string.Format("{0}/api/jobs/suggest?searchtext={1}&fuzzy={2}", ConfigurationManager.AppSettings["NYCJobsApi"], term, fuzzy);
                  var response = await client.GetStringAsync(uri);
                  suggresult = JsonConvert.DeserializeObject<DocumentSuggestResult>(response);
                }

                List<string> suggestions = new List<string>();
                foreach (var result in suggresult.Results)
                {
                    suggestions.Add(result.Text);
                }

                // Get unique items
                List<string> uniqueItems = suggestions.Distinct().ToList();

                return new JsonResult
                {
                    JsonRequestBehavior = JsonRequestBehavior.AllowGet,
                    Data = uniqueItems
                };
            }
            // app insight
            catch (Exception ex)
            {
                // Set up some properties:
                var properties = new Dictionary<string, string>
                    {   { "Term", term },
                        { "IsFuzzy", Convert.ToString(fuzzy) }
                    };

                // Send the exception telemetry:
                telemetry.TrackException(ex, properties);
                throw ex;
            }

        }

        public async Task<ActionResult> LookUp(string id)
        {
            try
            {
                telemetry.TrackEvent("LookUp called");

                // Set up some properties:
                var properties = new Dictionary<string, string>
                    {   { "id", id }
                    };

                telemetry.TrackTrace("LookUp called", properties);
                

                // Take a key ID and do a lookup to get the job details
                if (id != null)
                {
                    //var response = _jobsSearch.LookUp(id);
                    using (var client = new HttpClient())
                    {
                      client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", ConfigurationManager.AppSettings["Ocp-Apim-Subscription-Key"]);
                      var uri = string.Format("{0}/api/jobs/lookup?id={1}", ConfigurationManager.AppSettings["NYCJobsApi"],id);
                      var response = await client.GetStringAsync(uri);
                      var doc = JsonConvert.DeserializeObject<Document>(response);
                      return new JsonResult
                      {
                          JsonRequestBehavior = JsonRequestBehavior.AllowGet,
                          Data = new NYCJobLookup() { Result = doc }
                      };
                    }
                }
                else
                {
                    return null;
                }
            }
            // app insight
            catch (Exception ex)
            {
                // Set up some properties:
                var properties = new Dictionary<string, string>
                    {   { "Lookup Id", id }
                    };

                // Send the exception telemetry:
                telemetry.TrackException(ex, properties);
                throw ex;
            }



        }


        async public Task<ActionResult> ApplyNow(string jobId,string role, string location, string salary, string title, string email)
        {
            try
            {
                telemetry.TrackEvent("ApplyNow called");
                
                // Set up some properties:
                var properties = new Dictionary<string, string>
                    {   { "JobId", jobId },
                        { "Role", role },
                        { "Location", location },
                        { "Salary", salary },
                        { "Title", title },
                    };

                telemetry.TrackTrace("ApplyNow called", properties);

                // put the application on the queue
                var data = new Application()
                {
                   JobId = jobId,
                   Role = role,
                   Location = location,
                   Salary = salary,
                   Title = title,
                   Email = email
                };


                // arash track metric
                //long queueLength = nsmgr.GetQueue(queueName).MessageCount;
                //telemetry.TrackMetric("Service Bus queue lenght", queueLength);

                using (var client = new HttpClient())
                {
                  client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", ConfigurationManager.AppSettings["Ocp-Apim-Subscription-Key"]);
                  string req = JsonConvert.SerializeObject(data);
                  var uri = string.Format("{0}/api/jobs/apply", ConfigurationManager.AppSettings["NYCJobsApi"]);
                  HttpResponseMessage result = await client.PostAsync(uri, new StringContent(req, Encoding.Default, "application/json"));
                }

                return null;
            }
            // app insight
            catch (Exception ex)
            {
               
                // Send the exception telemetry:
                telemetry.TrackException(ex); //, properties);
                throw ex;
            }

        }


    }
}
