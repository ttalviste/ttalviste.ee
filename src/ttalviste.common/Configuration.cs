using System;

namespace ttalviste.common
{
    public class Configuration
    {
        public static string WebSiteName { get { return "ttalviste"; } }
        public static string ProductionGoogeAnalytics
        {
            get { return "UA-41092859-2"; }
        }
        public static string DevelopmentGoogeAnalytics
        {
            get { return "UA-41092859-3"; }
        }
    }
}
