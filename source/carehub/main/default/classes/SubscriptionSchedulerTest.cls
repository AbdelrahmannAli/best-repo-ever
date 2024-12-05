@isTest
public with sharing class SubscriptionSchedulerTest {
   
   @isTest
   static void subscriptionSchedulerTest_ScheduledCorrectly() {
      Date tomorrowDate = Date.today().addDays(1);
      Datetime nextTime = Datetime.newInstance(tomorrowDate, Time.newInstance(0, 0, 0, 0));
   String CRON_EXP = '0 0 0 ' + tomorrowDate.day() + ' ' + tomorrowDate.month() + ' ? '+ tomorrowDate.year(); 
      
      Test.startTest();
      String jobId = System.schedule('testSubscriptionScheduler', CRON_EXP, new SubscriptionScheduler());
      Test.stopTest();
      
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
      
      System.assertEquals(CRON_EXP, ct.CronExpression);
      System.assertEquals(0, ct.TimesTriggered);
      System.assertEquals(String.valueOf(nextTime), String.valueOf(ct.NextFireTime));
   }
}