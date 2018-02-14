using Microsoft.Azure.Search;
using Microsoft.Azure.Search.Models;
using Microsoft.ServiceBus.Messaging;
using Microsoft.Spatial;
using Newtonsoft.Json;
using Swashbuckle.Swagger.Annotations;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;

namespace NYCJobsApi.Controllers
{

    [ExceptionHandlingFilter]
    public class JobsController : ApiController
    {

        private static SearchServiceClient _searchClient;
        private static ISearchIndexClient _indexClient;
        private static string IndexName = "nycjobs";
        private static ISearchIndexClient _indexZipClient;
        private static string IndexZipCodes = "zipcodes";
        public static string errorMessage;

        static JobsController()
        {
            try
            {
                string searchServiceName = ConfigurationManager.AppSettings["SearchServiceName"];
                string apiKey = ConfigurationManager.AppSettings["SearchServiceApiKey"];

                // Create an HTTP reference to the catalog index
                _searchClient = new SearchServiceClient(searchServiceName, new SearchCredentials(apiKey));
                _indexClient = _searchClient.Indexes.GetClient(IndexName);
                _indexZipClient = _searchClient.Indexes.GetClient(IndexZipCodes);

            }
            catch (Exception e)
            {
                errorMessage = e.Message.ToString();
                throw e;
            }
        }


        [HttpGet]
        [Route("api/jobs/search")]
        [SwaggerOperation("Search")]
        public async Task<DocumentSearchResult> SearchAsync(string searchText = "",
                                                            string businessTitleFacet = "",
                                                            string postingTypeFacet = "",
                                                            string salaryRangeFacet = "",
                                                            string sortType = "",
                                                            double lat = 40.736224,
                                                            double lon = -73.99251,
                                                            int currentPage = 0,
                                                            int maxDistance = 0,
                                                            string maxDistanceLat = "1",
                                                            string maxDistanceLon = "1")
        {
            // Execute search based on query string
            try
            {

                SearchParameters sp = new SearchParameters()
                {
                    SearchMode = SearchMode.Any,
                    Top = 10,
                    Skip = currentPage,
                    // Limit results
                    Select = new List<String>() {"id", "agency", "posting_type", "num_of_positions", "business_title",
                        "salary_range_from", "salary_range_to", "salary_frequency", "work_location", "job_description",
                        "posting_date", "geo_location", "tags"},
                    // Add count
                    IncludeTotalResultCount = true,
                    // Add search highlights
                    HighlightFields = new List<String>() { "job_description" },
                    HighlightPreTag = "<b>",
                    HighlightPostTag = "</b>",
                    // Add facets
                    Facets = new List<String>() { "business_title", "posting_type", "level", "salary_range_from,interval:50000" },
                };
                // Define the sort type
                if (sortType == "featured")
                {
                    sp.ScoringProfile = "jobsScoringFeatured";      // Use a scoring profile
                    sp.ScoringParameters = new List<ScoringParameter>();
                    sp.ScoringParameters.Add(new ScoringParameter("featuredParam", new[] { "featured" }));
                    sp.ScoringParameters.Add(new ScoringParameter("mapCenterParam", GeographyPoint.Create(lon, lat)));
                }
                else if (sortType == "salaryDesc")
                    sp.OrderBy = new List<String>() { "salary_range_from desc" };
                else if (sortType == "salaryIncr")
                    sp.OrderBy = new List<String>() { "salary_range_from" };
                else if (sortType == "mostRecent")
                    sp.OrderBy = new List<String>() { "posting_date desc" };
                
                // Add filtering
                string filter = null;
                if (!string.IsNullOrEmpty(businessTitleFacet))
                    filter = "business_title eq '" + businessTitleFacet + "'";
                if (!string.IsNullOrEmpty(postingTypeFacet))
                {
                    if (filter != null)
                        filter += " and ";
                    filter += "posting_type eq '" + postingTypeFacet + "'";

                }
                if (!string.IsNullOrEmpty(salaryRangeFacet))
                {
                    if (filter != null)
                        filter += " and ";
                    filter += "salary_range_from ge " + salaryRangeFacet + " and salary_range_from lt " + (Convert.ToInt32(salaryRangeFacet) + 50000).ToString();
                }

                if (maxDistance > 0)
                {
                    if (filter != null)
                        filter += " and ";
                    filter += "geo.distance(geo_location, geography'POINT(" + maxDistanceLon + " " + maxDistanceLat + ")') le " + maxDistance.ToString();
                }

                sp.Filter = filter;

                return await _indexClient.Documents.SearchAsync(searchText, sp);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error querying index: {0}\r\n", ex.Message.ToString());
                throw ex;
            }
        }

        [HttpGet]
        [Route("api/jobs/searchzip")]
        [SwaggerOperation("SearchZip")]
        public async Task<DocumentSearchResult> SearchZipAsync(string zipCode)
        {
            // Execute search based on query string
            try
            {
                SearchParameters sp = new SearchParameters()
                {
                    SearchMode = SearchMode.All,
                    Top = 1,
                };
                return await _indexZipClient.Documents.SearchAsync(zipCode, sp);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error querying index: {0}\r\n", ex.Message.ToString());
                throw ex;
            }
        }

        [HttpGet]
        [Route("api/jobs/suggest")]
        [SwaggerOperation("Suggest")]
        public async Task<DocumentSuggestResult> Suggest(string searchText, bool fuzzy)
        {
            // Execute search based on query string
            try
            {
                SuggestParameters sp = new SuggestParameters()
                {
                    UseFuzzyMatching = fuzzy,
                    Top = 8
                };

                // evil bad code here :)
                Random r = new Random(DateTime.Now.Millisecond);
                var d = r.Next(0, 10) * 100;
                Task.Delay(d).Wait();
                // end evil bad code :)

                return await _indexClient.Documents.SuggestAsync(searchText, "sg", sp);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error querying index: {0}\r\n", ex.Message.ToString());
                throw ex;
            }

        }

        [HttpGet]
        [Route("api/jobs/lookup")]
        [SwaggerOperation("LookUp")]
        public async Task<Document> LookUp(string id)
        {
            // Execute geo search based on query string
            try
            {
                return await _indexClient.Documents.GetAsync(id);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error querying index: {0}\r\n", ex.Message.ToString());
                throw ex;
            }

        }

        [HttpPost]
        [Route("api/jobs/apply")]
        [SwaggerOperation("Apply")]
        [SwaggerResponse(HttpStatusCode.OK)]
        public async Task Apply([FromBody]Application application)
        {
            try
            {



                // send message to service bus
                var message = new BrokeredMessage(new MemoryStream(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(application))))
                {
                    ContentType = "application/json",
                    Label = "Application",
                    TimeToLive = TimeSpan.FromDays(14)
                };

                var client = QueueClient.CreateFromConnectionString(ConfigurationManager.AppSettings["ServiceBusConnection"]);
                await client.SendAsync(message);

              var message2 = new BrokeredMessage(new MemoryStream(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(application))))
              {
                ContentType = "application/json",
                Label = "Notification",
                TimeToLive = TimeSpan.FromDays(14)
              };

              var client2 = QueueClient.CreateFromConnectionString(ConfigurationManager.AppSettings["ServiceBusConnection"], "notificationqueue");
              await client2.SendAsync(message2);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error querying index: {0}\r\n", ex.Message.ToString());
                throw ex;
            }
        }

    }

    public class Application
    {
        public string JobId { get; set; }
        public string Role { get; set; }
        public string Location { get; set; }
        public string Salary { get; set; }
        public string Title { get; set; }
        public string Email { get; set; }

  }

}
