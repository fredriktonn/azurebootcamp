using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NYCJobsWeb.Models
{
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