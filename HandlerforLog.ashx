using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using log4net;
using System.Reflection;
//using log4net.Config;
//using log4net.Repository.Hierarchy;
//using log4net.Appender;
//using log4net.Layout;
//using log4net.Core;

namespace WebApp_log4net
{

    public class HandlerforLog : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            Write("Application is starting");
            context.Response.ContentType = "text/plain";
            context.Response.Write("Hello World");
        }

        public void Write(String message)
        {
            ILog myLog = GetDyamicLogger();
            myLog.Info("[Write]:" + message);
        }

        public static ILog GetDyamicLogger()
        {
            log4net.Repository.Hierarchy.Hierarchy hierarchy = 
            (log4net.Repository.Hierarchy.Hierarchy)LogManager.GetRepository();
            log4net.Appender.RollingFileAppender roller = 
              new log4net.Appender.RollingFileAppender();
            roller.LockingModel = new log4net.Appender.FileAppender.MinimalLock();
            roller.AppendToFile = true;
            roller.RollingStyle = 
               log4net.Appender.RollingFileAppender.RollingMode.Composite;
            roller.MaxSizeRollBackups = 29; // 0~29 is 30. 
            roller.MaximumFileSize = "10MB";
            roller.DatePattern = "yyyyMMdd";
            roller.Layout = new log4net.Layout.PatternLayout();
            roller.File = "log\\debug.log";
            roller.StaticLogFileName = true;

            log4net.Layout.PatternLayout patternLayout = 
                  new log4net.Layout.PatternLayout();
            patternLayout.ConversionPattern = 
             @"%date [%thread] %-5level %logger [%property{NDC}] - %message%newline";
            patternLayout.ActivateOptions();

            roller.Layout = patternLayout;
            roller.ActivateOptions();
            hierarchy.Root.AddAppender(roller);

            hierarchy.Root.Level = log4net.Core.Level.All;
            hierarchy.Configured = true;

            DummyLogger dummyILogger = new DummyLogger("LogName");
            dummyILogger.Hierarchy = hierarchy;
            dummyILogger.Level = log4net.Core.Level.All;
            dummyILogger.AddAppender(roller);

            return new log4net.Core.LogImpl(dummyILogger);
        }

        internal sealed class DummyLogger : log4net.Repository.Hierarchy.Logger
        {
            // Methods
            internal DummyLogger(string name)
                : base(name)
            {
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}