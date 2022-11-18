package ep;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class BackgroundJobManager implements ServletContextListener {

private ScheduledExecutorService scheduler;

@Override
public void contextInitialized(ServletContextEvent event) {
    scheduler = Executors.newSingleThreadScheduledExecutor();
   // scheduler.scheduleAtFixedRate(new DailyJob(), 0, 1, TimeUnit.DAYS);
   // scheduler.scheduleAtFixedRate(new HourlyJob(), 0, 1, TimeUnit.HOURS);
   // scheduler.scheduleAtFixedRate(new MinJob(), 0, 1, TimeUnit.MINUTES);
   scheduler.scheduleAtFixedRate(new EPBatchJob(), 0, 60, TimeUnit.SECONDS); /* 매 일분에 한번은 실행함 */
}

@Override
public void contextDestroyed(ServletContextEvent event) {
    scheduler.shutdownNow();
}

}
