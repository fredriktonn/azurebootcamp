using Microsoft.ApplicationInsights;
using System;
using System.Diagnostics;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Filters;

namespace NYCJobsApi
{


    public class ExceptionHandlingFilter : ExceptionFilterAttribute
    {
        private TelemetryClient telemetry = new TelemetryClient();

        public override void OnException(HttpActionExecutedContext context)
        {
            telemetry.TrackException(context.Exception);

            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError)
            {
                Content = new StringContent(context.Exception.ToString()),
                ReasonPhrase = context.Exception.Message
            });
        }
    }
}